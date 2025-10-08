#!/usr/bin/env python3


"""
A Python daemon that continuously monitors Arch and AUR package updates.
Writes the output to $XDG_RUNTIME_DIR for waybar consumption.
"""


import asyncio
import json
import os
import signal
import sys
from datetime import datetime
from pathlib import Path


class UpdatesMonitor:
    def __init__(self):
        self.signal_event = asyncio.Event()

    def _print(self, *args, **kwargs):
        """Print with flush=True to ensure immediate output"""
        print(*args, **kwargs, flush=True)

    def _write_json(self, text="", tooltip="", class_name=""):
        """Write waybar JSON format to output file"""
        data = {"text": text, "tooltip": tooltip, "class": class_name}

        try:
            with open(self.output_file, "w", encoding="utf-8") as f:
                json.dump(data, f, ensure_ascii=False)
                f.write("\n")
        except Exception as e:
            # If we have an error writing the json file we have no way to
            # communicate, might as well exit
            self._print(f"Unexpected error while writing json file: {e}")
            sys.exit(1)

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
        self._print("Checking for updates...")
        self._write_json("", "Checking updates...", "checking")

        try:
            arch_updates, aur_updates = await asyncio.gather(
                self._get_arch_updates(), self._get_aur_updates()
            )

            self._print(
                f"Found {arch_updates} Arch updates, {aur_updates} AUR updates"
            )

            if arch_updates == 0 and aur_updates == 0:
                # No updates
                current_time = datetime.now().strftime("%H:%M")
                self._write_json(
                    "",
                    f"No updates found\nLast checked: {current_time}",
                    "none",
                )
            else:
                # Updates available
                tooltips = []
                classes = []

                if arch_updates > 0:
                    tooltips.append(f"Arch updates: {arch_updates}")
                    classes.append("arch")

                if aur_updates > 0:
                    tooltips.append(f"AUR updates: {aur_updates}")
                    classes.append("aur")

                self._write_json("", "\n".join(tooltips), "_".join(classes))

        except Exception as e:
            self._print(f"Error during update check: {e}")
            self._write_json("!", f"Error checking updates\n{e}", "error")

    async def run(self):
        """Main loop"""
        try:
            self._print("Starting waybar updates monitor")

            xdg_runtime_dir = Path(os.environ["XDG_RUNTIME_DIR"])
            self.output_file = xdg_runtime_dir / "arch_updates_monitor.json"

            loop = asyncio.get_running_loop()
            loop.add_signal_handler(signal.SIGUSR1, self.signal_event.set)

            # Main loop - check every hour or on signal
            while True:
                await self._check_updates()

                self._print("Waiting for next check (1 hour) or signal...")
                self.signal_event.clear()
                try:
                    await asyncio.wait_for(self.signal_event.wait(), timeout=3600)
                    self._print(
                        "Received signal, checking updates immediately"
                    )
                except asyncio.TimeoutError:
                    pass

        except Exception as e:
            self._print(f"Unexpected error: {e}")
            self._write_json(
                "!",
                f"Unexpected error, terminating updates monitor\n{e}",
                "error",
            )
            raise


if __name__ == "__main__":
    monitor = UpdatesMonitor()
    asyncio.run(monitor.run())
