"""
Monitors internet connectivity by checking multiple network layers. Performs
gateway ping, internet ping, and HTTP 204 test.
"""


import asyncio
import aiohttp
from dataclasses import dataclass
from enum import Enum
from typing import ClassVar, Optional

from .base_monitor import BaseMonitor


class ConnectivityStatus(Enum):
    FAILED = "FAILED"
    CHOPPY = "CHOPPY"
    SUCCESS = "SUCCESS"
    CAPTIVE = "CAPTIVE"
    UNKNOWN = "UNKNOWN"


@dataclass
class PingResult:
    successful: int
    total: int

    FAILED: ClassVar["PingResult"]

    @classmethod
    def from_results(cls, results: list[bool]) -> "PingResult":
        return cls(
            successful=sum(results),
            total=len(results)
        )

    @property
    def status(self) -> ConnectivityStatus:
        if self.successful == 0:
            return ConnectivityStatus.FAILED
        elif self.successful == self.total:
            return ConnectivityStatus.SUCCESS
        else:
            return ConnectivityStatus.CHOPPY

    def __str__(self):
        return f"{self.status.value} ({self.successful}/{self.total})"

PingResult.FAILED = PingResult(successful=0, total=0)


class InternetMonitor(BaseMonitor):
    def __init__(self):
        super().__init__("internet_monitor.json")
        self.default_gateway: Optional[PingResult] = None
        self.internet_ping: Optional[PingResult] = None
        self.internet_204: ConnectivityStatus = ConnectivityStatus.UNKNOWN
        self.internet_working = asyncio.Event()
        self._last_status_log = ""

        self.target_ip = "8.8.8.8"
        self.test_url_204 = "http://clients3.google.com/generate_204"

    def write_json(self, text="", tooltip="", class_name=""):
        # To keep track of status changes in the log but not spam, print the
        # tooltip only if it's different from the last log
        message = tooltip.replace("\n", " ")
        # Empty tooltip is a special case
        if not message:
            message = "Internet connection working"
        if self._last_status_log != message:
            self.log(message)
            self._last_status_log = message
        return super().write_json(text, tooltip, class_name)

    async def _run_ping_command(
        self, ttl: Optional[int], timeout: int = 3
    ) -> bool:
        """
        Execute ping command asynchronously.
        """
        ping_type = f"TTL={ttl}" if ttl else "normal"

        try:
            cmd = ["ping", "-c", "1", "-W", str(timeout)]
            if ttl:
                cmd.extend(["-t", str(ttl)])

            cmd.append(self.target_ip)

            # Run the command
            process = await asyncio.create_subprocess_exec(
                *cmd,
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE
            )

            try:
                stdout, stderr = await asyncio.wait_for(
                    process.communicate(),
                    timeout=timeout + 0.5  # Add small buffer to timeout
                )
            except asyncio.TimeoutError:
                process.kill()
                await process.communicate()
                return False

            output = stdout.decode("utf-8", errors="ignore").lower()

            # Check for success conditions
            if ttl == 1:
                # For TTL=1, we expect "Time to live exceeded" or similar
                ttl_exceeded_messages = [
                    "time to live exceeded",
                    "ttl exceeded",
                    "time exceeded",
                    "hop limit exceeded"
                ]
                success = any(msg in output for msg in ttl_exceeded_messages)
            else:
                # For normal ping, check for success indicators
                success_indicators = [
                    "bytes from",
                    "reply from",
                    "64 bytes",
                    "32 bytes"
                ]
                success = any(
                    indicator in output for indicator in success_indicators
                )

            return success

        except Exception as e:
            self.log(
                f"Ping ({ping_type}) to {self.target_ip} finished: FAILED (exception: {e})"
            )
            return False

    async def check_http_204(self):
        try:
            resolver = aiohttp.resolver.AsyncResolver(
                nameservers=["8.8.8.8", "8.8.4.4"]
            )
            connector = aiohttp.TCPConnector(resolver=resolver)
            timeout = aiohttp.ClientTimeout(total=5)
            async with aiohttp.ClientSession(
                connector=connector, timeout=timeout
            ) as session:
                async with session.get(
                    self.test_url_204, allow_redirects=False
                ) as response:
                    if response.status == 204:
                        self.internet_204 = ConnectivityStatus.SUCCESS
                    else:
                        self.internet_204 = ConnectivityStatus.CAPTIVE
        except Exception as e:
            self.log(f"HTTP test failed: {e}")
            self.internet_204 = ConnectivityStatus.FAILED

    async def _run_multiple_pings(
        self, ttl: Optional[int], count: int, delay: float = 0.5
    ) -> set:
        """
        Create multiple ping tasks and return the set of running tasks.
        """
        tasks = set()
        for i in range(count):
            async def ping_with_delay(iteration):
                await asyncio.sleep(iteration * delay)
                return await self._run_ping_command(ttl)
            task = asyncio.create_task(ping_with_delay(i))
            tasks.add(task)
        return tasks

    async def check_connectivity(self):
        """
        Main method to check all connectivity levels.
        Sets the instance variables with results.
        """

        # Uses a pipelined approach where each stage starts as soon as the
        # first successful ping from the previous stage completes.
        # - Gateway pings start immediately
        # - First gateway success -> internet pings start (gateway continues)
        # - First internet success -> HTTP check starts (both continue)

        all_running_tasks = set()

        gateway_tasks = set()
        internet_tasks = set()
        http_task = None

        gateway_results = []
        internet_results = []

        internet_started = False
        http_started = False

        gateway_tasks = await self._run_multiple_pings(ttl=1, count=5)
        all_running_tasks.update(gateway_tasks)

        while all_running_tasks:
            done, pending = await asyncio.wait(
                all_running_tasks, return_when=asyncio.FIRST_COMPLETED
            )
            all_running_tasks.difference_update(done)

            for task in done:
                if task == http_task:
                    continue

                result = await task

                if task in gateway_tasks:
                    gateway_results.append(result)

                    if result and not internet_started:
                        internet_tasks = await self._run_multiple_pings(
                            ttl=None, count=3
                        )
                        all_running_tasks.update(internet_tasks)
                        internet_started = True

                elif task in internet_tasks:
                    internet_results.append(result)

                    if result and not http_started:
                        http_task = asyncio.create_task(self.check_http_204())
                        all_running_tasks.add(http_task)
                        http_started = True

        self.default_gateway = PingResult.from_results(gateway_results)

        if internet_started:
            self.internet_ping = PingResult.from_results(internet_results)
        else:
            self.internet_ping = PingResult.FAILED

        if not http_started:
            self.internet_204 = ConnectivityStatus.FAILED

        if self.default_gateway.status != ConnectivityStatus.SUCCESS:
            self.write_json(
                "⚠",
                f"Pings to default gateway:\n{self.default_gateway}",
                "warning"
                if self.default_gateway.status == ConnectivityStatus.CHOPPY
                else "critical",
            )
        elif self.internet_ping.status != ConnectivityStatus.SUCCESS:
            self.write_json(
                "",
                f"Pings to internet:\n{self.internet_ping}",
                "warning"
                if self.internet_ping.status == ConnectivityStatus.CHOPPY
                else "critical",
            )
        else:
            match self.internet_204:
                case ConnectivityStatus.FAILED:
                    self.write_json(
                        "", "HTTP connection to 204 check failed", "critical"
                    )
                case ConnectivityStatus.CAPTIVE:
                    self.write_json("", "Captive portal detected", "warning")
                case _:
                    self.write_json("", "", "")

        if self.internet_204 == ConnectivityStatus.SUCCESS:
            self.internet_working.set()
        else:
            self.internet_working.clear()

    async def run(self):
        """Main loop"""
        try:
            # First thing put empty status to not show errors before the
            # internet check even ran
            self.write_json("", "Starting...", "")

            # Main loop - check every 10 seconds
            while True:
                await self.check_connectivity()
                await asyncio.sleep(10)

        except Exception as e:
            self.log(f"Unexpected error: {e}")
            self.write_json(
                "!",
                f"Unexpected error, terminating monitor\n{e}",
                "critical",
            )
            raise
