"""
# A Python daemon that continuously monitors Arch and AUR package updates. It
# runs in the background checking for updates hourly or instantly via `pkill
# -USR1` and writes JSON status to `$XDG_RUNTIME_DIR` for waybar consumption.
"""


import asyncio
import signal
from datetime import datetime

from .base_monitor import BaseMonitor
from .internet import InternetMonitor


class UpdatesMonitor(BaseMonitor):
    def __init__(self, internet_monitor: InternetMonitor):
        super().__init__("arch_updates_monitor.json")
        self.signal_event = asyncio.Event()
        self.internet_monitor = internet_monitor

    async def _get_arch_updates(self):
        """Get number of Arch updates"""
        proc = await asyncio.create_subprocess_exec(
            "checkupdates",
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE,
        )
        try:
            stdout, stderr = await asyncio.wait_for(
                proc.communicate(), timeout=90
            )
            lines = stdout.decode().strip().split("\n")
            return len([line for line in lines if line.strip()])
        except asyncio.TimeoutError:
            proc.kill()
            await proc.wait()
            raise RuntimeError("Arch updates check timed out")

    async def _get_aur_updates(self):
        """Get number of AUR updates"""
        proc = await asyncio.create_subprocess_exec(
            "pikaur",
            "-Qua",
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE,
        )
        try:
            stdout, stderr = await asyncio.wait_for(
                proc.communicate(), timeout=90
            )
            if proc.returncode != 0:
                raise Exception(f"pikaur exited with code {proc.returncode}")
            lines = stdout.decode().strip().split("\n")
            return len([line for line in lines if line.strip()])
        except asyncio.TimeoutError:
            proc.kill()
            await proc.wait()
            raise RuntimeError("AUR check timed out")

    async def _check_updates(self):
        """Check for updates and write result"""
        self.log("Checking for updates...")
        self.write_json("", "Checking updates...", "checking")

        try:
            arch_updates, aur_updates = await asyncio.gather(
                self._get_arch_updates(), self._get_aur_updates()
            )

            self.log(
                f"Found {arch_updates} Arch updates, {aur_updates} AUR updates"
            )

            if arch_updates == 0 and aur_updates == 0:
                current_time = datetime.now().strftime("%H:%M")
                self.write_json(
                    "",
                    f"No updates found\nLast checked: {current_time}",
                    "none",
                )
            else:
                tooltips = []
                classes = []

                if arch_updates > 0:
                    tooltips.append(f"Arch updates: {arch_updates}")
                    classes.append("arch")

                if aur_updates > 0:
                    tooltips.append(f"AUR updates: {aur_updates}")
                    classes.append("aur")

                self.write_json("", "\n".join(tooltips), "_".join(classes))

        except Exception as e:
            self.log(f"Error during update check: {e}")
            self.write_json("!", f"Error checking updates\n{e}", "error")

    async def run(self):
        """Main loop"""
        try:
            self.log("Starting waybar updates monitor")

            loop = asyncio.get_running_loop()
            loop.add_signal_handler(signal.SIGUSR1, self.signal_event.set)

            # Main loop - check every hour or on signal
            while True:
                if not self.internet_monitor.internet_working.is_set():
                    self.write_json("", "", "")
                    await self.internet_monitor.internet_working.wait()

                await self._check_updates()

                self.log("Waiting for next check (1 hour) or signal...")
                self.signal_event.clear()
                try:
                    await asyncio.wait_for(self.signal_event.wait(), timeout=3600)
                    self.log("Received signal, checking updates immediately")
                except asyncio.TimeoutError:
                    pass

        except Exception as e:
            self.log(f"Unexpected error: {e}")
            self.write_json(
                "!",
                f"Unexpected error, terminating monitor\n{e}",
                "error",
            )
            raise
