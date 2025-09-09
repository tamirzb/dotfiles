#!/usr/bin/env python3


"""
A Python daemon that continuously monitors Arch and AUR package updates.
Writes the output to $XDG_RUNTIME_DIR for waybar consumption.
"""


import json
import os
import signal
import subprocess
import sys
from datetime import datetime
from pathlib import Path


class UpdatesMonitor:
    def _print(self, *args, **kwargs):
        """Print with flush=True to ensure immediate output"""
        print(*args, **kwargs, flush=True)

    def _handle_signal(self, signum, frame):
        """Handle USR1 signal to trigger immediate update check"""
        self._print(f"Received signal {signum}, checking updates immediately")

    def _handle_alarm(self, signum, frame):
        """Handle alarm timeout signal"""
        pass

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

    def _check_internet(self):
        """Check internet connectivity"""
        try:
            result = subprocess.run(
                ["ping", "-q", "-w", "2", "-c", "1", "8.8.8.8"],
                stdout=subprocess.DEVNULL,
                timeout=5,
            )
            return result.returncode == 0
        except Exception as e:
            self._print(f"Internet check failed: {e}")
            return False

    def _get_arch_updates(self):
        """Get number of Arch updates"""
        result = subprocess.run(
            ["checkupdates"], capture_output=True, text=True, timeout=90
        )
        lines = result.stdout.strip().split("\n")
        return len([line for line in lines if line.strip()])

    def _get_aur_updates(self):
        """Get number of AUR updates"""
        result = subprocess.run(
            ["pikaur", "-Qua"],
            capture_output=True,
            text=True,
            timeout=90,
            check=True,
        )
        # Count non-empty lines
        lines = result.stdout.strip().split("\n")
        return len([line for line in lines if line.strip()])

    def _check_updates(self):
        """Check for updates and write result"""
        self._print("Checking for updates...")
        self._write_json("", "Checking updates...", "checking")

        try:
            arch_updates = self._get_arch_updates()
            aur_updates = self._get_aur_updates()

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
            self._write_json("!", "Error checking updates\n{e}", "error")

    def _wait_with_timeout(self, timeout_seconds):
        """Wait for signal with timeout using alarm"""
        # Wait for any signal, with a maximum of timeout_seconds as a SIGALRM
        # will be sent after that
        signal.alarm(timeout_seconds)
        signal.pause()
        signal.alarm(0)  # Cancel alarm

    def _wait_for_internet(self):
        """Wait for internet connection with 20s retry"""
        while not self._check_internet():
            self._print("No internet connection, waiting...")
            self._write_json("", "", "")

            # Wait 20 seconds or until USR1 signal received
            self._wait_with_timeout(20)

    def run(self):
        """Main loop"""
        try:
            self._print("Starting waybar updates monitor")

            xdg_runtime_dir = Path(os.environ["XDG_RUNTIME_DIR"])
            self.output_file = xdg_runtime_dir / "arch_updates_monitor.json"

            # Setup signal handlers
            signal.signal(signal.SIGUSR1, self._handle_signal)
            signal.signal(signal.SIGALRM, self._handle_alarm)

            # Main loop - check every hour or on signal
            while True:
                self._wait_for_internet()

                self._check_updates()

                # Wait for 1 hour (3600 seconds) or until USR1 signal
                self._print("Waiting for next check (1 hour) or signal...")
                self._wait_with_timeout(3600)
        except Exception as e:
            self._print(f"Unexpected error: {e}")
            self._write_json(
                "!",
                "Unexpected error, terminating updates monitor\n{e}",
                "error",
            )
            raise


if __name__ == "__main__":
    monitor = UpdatesMonitor()
    monitor.run()
