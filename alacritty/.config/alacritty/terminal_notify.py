#!/usr/bin/python
# ^ Use this instead of /usr/bin/env python because I actually want to make
# sure this always uses system python and never ends up running from a venv

"""
This script is executed by programs running on a terminal to notify they
finished processing. If the terminal running the program is not focused it
shows a notification using notify-send, which can be clicked to focus on the
alacritty window.
"""

import os
import sys
import subprocess
import argparse
from i3ipc import Connection

# The process name of the terminal we look for
TERMINAL_PROCESS_NAME = "alacritty"


def daemonize():
    """
    Switch execution from now on to a separate daemon process
    """
    if os.fork() != 0:
        sys.exit(0)

    # Child continues
    # Redirect standard file descriptors to /dev/null
    with open("/dev/null", "r") as devnull:
        os.dup2(devnull.fileno(), sys.stdin.fileno())
    with open("/dev/null", "w") as devnull:
        os.dup2(devnull.fileno(), sys.stdout.fileno())
        os.dup2(devnull.fileno(), sys.stderr.fileno())


def find_parent_pid_with_name(process_to_find):
    """
    Traverses up the process tree to find the PID of the parent process whose
    name matches the one provided
    """
    try:
        pid = os.getpid()
        # Loop until we reach the 'init' process (pid 1) or find the process
        while pid > 1:
            # Construct the path to the process's status file
            status_path = f"/proc/{pid}/status"

            with open(status_path, "r") as f:
                proc_name = ""
                parent_pid = None
                # Read the status file to find the process name and its parent's PID
                for line in f:
                    if line.startswith("Name:"):
                        proc_name = line.split("\t")[1].strip()
                    elif line.startswith("PPid:"):
                        parent_pid = int(line.split("\t")[1].strip())

            # Check if the current process in the chain is the one we look for
            if proc_name == process_to_find:
                return pid

            # If not, move up to the parent process.
            # This check is crucial to prevent an infinite loop if PPid isn't
            # found.
            if parent_pid is not None and parent_pid != pid:
                pid = parent_pid
            else:
                break  # Reached the top of this process branch

    except (FileNotFoundError, IndexError, ValueError):
        # A FileNotFoundError can happen if a process in the chain terminates
        # while the script is running. Other errors are for safety.
        return None

    return None


def main():
    parser = argparse.ArgumentParser(description="Notify when terminal program finishes")
    parser.add_argument("title", help="Notification title")
    parser.add_argument("description", nargs="?", default="", help="Notification description")
    parser.add_argument("--always-show", action="store_true", help="Always show notification without checking focus")

    args = parser.parse_args()

    alacritty_pid = find_parent_pid_with_name(TERMINAL_PROCESS_NAME)
    if not alacritty_pid:
        raise RuntimeError("Parent alacritty process not found")

    sway = Connection()

    if not args.always_show:
        alacritty_windows = sway.get_tree().find_by_pid(alacritty_pid)
        if not alacritty_windows:
            raise RuntimeError("Alacritty window not found")
        if len(alacritty_windows) > 1:
            raise RuntimeError(
                "Unexpected: Alacritty has more than one window"
            )

        alacritty_window = alacritty_windows[0]
        if alacritty_window.focused:
            # Window already focused
            return

    # For notifying the user fork to a different process. This allows waiting
    # for the result of notify-send but also returning immediately so the
    # program is not stuck waiting for this script
    daemonize()

    # Show the notification using notify-send
    result = subprocess.run(
        [
            "notify-send",
            "-A",
            "default=Activate",
            args.title,
            args.description,
        ],
        capture_output=True,
        text=True,
        # Raise CalledProcessError if notify-send returns non-zero exit code
        check=True,
    )
    # If the user clicked the notification, focus on alacritty
    if result.stdout.strip() == "default":
        sway.command(f"[pid={alacritty_pid}] focus")


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(e, file=sys.stderr)
        sys.exit(1)
