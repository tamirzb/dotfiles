#!/usr/bin/env python3

"""
This script runs in the background for Sway WM. It monitors changes in
connected/active displays and the laptop lid state. It automatically turns off
the laptop screen when docked or external monitors are connected, or when the
lid is closed, and turns it back on when they are disconnected (and the lid is
open).

It can be controlled via signals:
- SIGUSR1: Toggles the script's enabled state. When disabled, the laptop
           monitor is forced on and no further state changes occur until
           re-enabled. When re-enabled, it immediately re-evaluates the
           correct state.
- SIGUSR2: Triggers an immediate re-evaluation of the display state. This is
           intended to be used with a Sway bindswitch for lid events.
"""

import sys
import subprocess
import json
import logging
import signal
import os
import atexit
import glob

logging.basicConfig(
    format='%(asctime)s %(levelname)s %(message)s',
    datefmt='%Y-%m-%d %H:%M:%S',
    level=logging.INFO
)
logger = logging.getLogger(__name__)

# Global variable to hold the manager instance
# This is needed so the signal handlers can access it
manager_instance = None

# Define the PID file path
XDG_RUNTIME_DIR = os.environ.get('XDG_RUNTIME_DIR')
if not XDG_RUNTIME_DIR:
    logger.error("$XDG_RUNTIME_DIR is not set. Cannot create PID file.")
    sys.exit(1)

PID_FILE = os.path.join(XDG_RUNTIME_DIR, 'sway-manage-laptop-display.pid')

def remove_pid_file():
    """Removes the PID file on script exit."""
    if os.path.exists(PID_FILE):
        try:
            os.remove(PID_FILE)
            logger.info(f"Removed PID file: {PID_FILE}")
        except OSError as e:
            # Only log the error as this is an atexit handler
            logger.error(f"Error removing PID file {PID_FILE}: {e}")

def reset_sway_bindswitch():
    """Resets the Sway bindswitch for lid toggle on script exit."""
    try:
        # Set the command to an empty string to reset it
        run_swaymsg(['bindswitch --locked lid:toggle ""'])
        logger.info("Sway bindswitch for lid:toggle reset successfully.")
    except Exception as e:
        # Only log the error as this is an atexit handler
        logger.error(f"Failed to reset Sway bindswitch: {e}")

def run_swaymsg(command: list[str]):
    """Helper function to run swaymsg commands."""
    cmd = ['swaymsg'] + command
    try:
        result = subprocess.run(
            cmd, check=True, capture_output=True, text=True
        )
        return result
    except FileNotFoundError:
        raise FileNotFoundError(
            "'swaymsg' command not found. Is Sway installed and in your " +
            "PATH?"
        )
    except subprocess.CalledProcessError as e:
        error_msg = f"Error running swaymsg command: {' '.join(cmd)}\n"
        error_msg += f"Return code: {e.returncode}\n"
        if e.stdout:
            error_msg += f"Stdout: {e.stdout.strip()}\n"
        if e.stderr:
            error_msg += f"Stderr: {e.stderr.strip()}"
        raise RuntimeError(error_msg)
    except Exception as e:
        raise RuntimeError(
            "An unexpected error occurred while running swaymsg: " +
            f"{e}"
        )

class LaptopDisplayManager:
    """
    Manages the state of the laptop display based on the presence of other
    active monitors in Sway and the laptop lid state. Can be enabled/disabled
    via signals.
    """
    def __init__(self, laptop_monitor_name):
        self.laptop_monitor_name = laptop_monitor_name
        self.is_enabled = True

    @staticmethod
    def _is_lid_open():
        """
        Checks the laptop lid state by reading /proc/acpi/button/lid/*/state.
        Returns True if open, False if closed.
        Raises RuntimeError if the state cannot be determined.
        """
        lid_state_files = glob.glob('/proc/acpi/button/lid/*/state')
        if not lid_state_files:
            raise RuntimeError(
                "Could not find /proc/acpi/button/lid/*/state. " +
                "Cannot determine lid state."
            )

        # Assuming the first file found is the correct one
        lid_state_file = lid_state_files[0]

        try:
            with open(lid_state_file, 'r') as f:
                content = f.read().strip()
                if 'state:      open' in content:
                    return True
                elif 'state:      closed' in content:
                    return False
                else:
                    raise RuntimeError(
                        f"Unexpected content in {lid_state_file}: {content}"
                    )
        except IOError as e:
            raise RuntimeError(
                f"Error reading lid state file {lid_state_file}: {e}"
            ) from e


    def toggle_enabled_state(self):
        """Toggles the enabled state of the manager."""
        self.is_enabled = not self.is_enabled
        state_str = "Enabled" if self.is_enabled else "Disabled"
        logger.info(f"Toggled manager state to: {state_str}")

        if not self.is_enabled:
            logger.info(
                "Manager disabled. Ensuring " +
                f"{self.laptop_monitor_name} is enabled."
            )
            run_swaymsg(['output', self.laptop_monitor_name, 'enable'])
        else:
            logger.info(
                "Manager enabled. Re-evaluating display state."
            )
            self.update_monitor_state()

    def update_monitor_state(self):
        """
        Determines desired laptop monitor state based on other active outputs
        and the lid state, and executes the swaymsg command to set the state,
        but only if enabled.
        Raises RuntimeError on failure.
        """
        logger.info("Checking current display state...")

        # Always turn off display if lid is closed
        lid_is_open = self._is_lid_open()
        if not lid_is_open:
            logger.info("Lid is closed. Ensuring laptop monitor is disabled.")
            run_swaymsg(['output', self.laptop_monitor_name, 'disable'])
            return

        # Otherwise if lid is open and the manager is not enabled then always
        # turn on the display
        if not self.is_enabled:
            logger.info(
                "Manager is disabled. Ensuring laptop monitor is enabled."
            )
            run_swaymsg(['output', self.laptop_monitor_name, 'enable'])
            return

        # Only if lid is open and manager is enabled then go with its logic
        result = run_swaymsg(['-t', 'get_outputs'])

        try:
            outputs = json.loads(result.stdout)
        except json.JSONDecodeError:
            error_msg = "Failed to parse JSON output from swaymsg."
            logger.error(error_msg)
            logger.error(f"Received output:\n{result.stdout[:500]}...")
            raise RuntimeError(error_msg)

        # Count active monitors *excluding* our laptop monitor
        other_active_monitors_count = 0
        for output in outputs:
            if (output.get('active', False) and
                    output.get('name') != self.laptop_monitor_name):
                other_active_monitors_count += 1

        logger.info(
            f"Found {other_active_monitors_count} other active monitor(s)."
        )

        # Find the laptop output specifically for state check
        laptop_output = next(
            (o for o in outputs if o.get('name') == self.laptop_monitor_name),
            None
        )

        if not laptop_output:
            error_msg = (
                f"Laptop monitor {self.laptop_monitor_name} not found in " +
                "swaymsg outputs."
            )
            logger.error(error_msg)
            raise RuntimeError(error_msg)

        if other_active_monitors_count == 0:
            logger.info(
                "Condition: No other active monitors detected. " +
                f"Ensuring {self.laptop_monitor_name} is enabled."
            )
            if not laptop_output.get('active', False):
                logger.info(
                    f"Laptop monitor {self.laptop_monitor_name} is currently " +
                    "disabled. Enabling..."
                )
                run_swaymsg(['output', self.laptop_monitor_name, 'enable'])
            else:
                 logger.info(
                     f"Laptop monitor {self.laptop_monitor_name} is already " +
                     "enabled."
                 )

        else:
            logger.info(
                f"Condition: {other_active_monitors_count} other monitor(s) " +
                f"active. Ensuring {self.laptop_monitor_name} is disabled."
            )
            if laptop_output.get('active', False):
                logger.info(
                    f"Laptop monitor {self.laptop_monitor_name} is currently " +
                    "enabled. Disabling..."
                )
                run_swaymsg(['output', self.laptop_monitor_name, 'disable'])
            else:
                 logger.info(
                     f"Laptop monitor {self.laptop_monitor_name} is already " +
                     "disabled."
                 )

    def run_loop(self):
        """
        Starts the event monitoring loop, reacting to Sway 'output' events.
        This loop will exit if an exception occurs during event processing.
        """
        # Check if swaymsg is available before proceeding by trying to run a
        # simple command. run_swaymsg will raise if it fails.
        run_swaymsg(['-v'])

        logger.info(
            "Starting laptop display manager loop for Sway " +
            f"({self.laptop_monitor_name})..."
        )

        # Initial check when the script starts.
        self.update_monitor_state()

        # Event monitoring loop
        while True:
            logger.info("Waiting for next Sway 'output' event...")
            # Run the subscribe command. This will block until an event happens
            # and exit after each event.
            run_swaymsg(['-t', 'subscribe', '["output"]'])

            logger.info("Sway 'output' event detected.")
            self.update_monitor_state()
            # The loop repeats, starting the next swaymsg subscribe command.

# Signal handler function for SIGUSR1
def handle_sigusr1(signum, frame):
    """Signal handler for SIGUSR1."""
    global manager_instance
    if manager_instance:
        logger.info("Received SIGUSR1 signal.")
        try:
            manager_instance.toggle_enabled_state()
        except Exception as e:
            logger.error(f"Error in SIGUSR1 handler: {e}")
            sys.exit(1)
    else:
        logger.warning(
            "Received SIGUSR1 but manager_instance is not set."
        )

# Signal handler function for SIGUSR2
def handle_sigusr2(signum, frame):
    """Signal handler for SIGUSR2."""
    global manager_instance
    if manager_instance:
        logger.info("Received SIGUSR2 signal (Lid toggle event).")
        try:
            manager_instance.update_monitor_state()
        except Exception as e:
            logger.error(f"Error in SIGUSR2 handler: {e}")
            sys.exit(1)
    else:
        logger.warning(
            "Received SIGUSR2 but manager_instance is not set."
        )

def main(laptop_monitor_name):
    global manager_instance

    # Check if PID file already exists
    if os.path.exists(PID_FILE):
        raise RecursionError(
            f"PID file already exists at {PID_FILE}. " +
            "Another instance of the script might be running."
        )

    # Write current PID to file
    pid = os.getpid()
    try:
        with open(PID_FILE, 'w') as f:
            f.write(str(pid))
        logger.info(f"Wrote PID {pid} to {PID_FILE}")
    except IOError as e:
        error_msg = f"Could not write PID file {PID_FILE}: {e}"
        logger.error(error_msg)
        raise IOError(error_msg) from e

    # Register cleanup function to remove PID file on exit
    atexit.register(remove_pid_file)

    # Register cleanup function to reset the bindswitch on exit
    atexit.register(reset_sway_bindswitch)

    # Create the manager instance and store it globally
    manager_instance = LaptopDisplayManager(laptop_monitor_name)

    # Register signal handlers
    signal.signal(signal.SIGUSR1, handle_sigusr1)
    logger.info("SIGUSR1 handler registered.")
    signal.signal(signal.SIGUSR2, handle_sigusr2)
    logger.info("SIGUSR2 handler registered.")

    # Set up Sway bindswitch for lid events
    try:
        run_swaymsg([f"bindswitch --locked lid:toggle exec kill -USR2 {pid}"])
        logger.info("Sway bindswitch successfully set.")
    except Exception as e:
        error_msg = f"Failed to set Sway bindswitch: {e}"
        logger.error(error_msg)
        raise RuntimeError(error_msg) from e

    # Start the main loop. This will run until an exception occurs.
    manager_instance.run_loop()

if __name__ == "__main__":
    # Check if the laptop monitor name is provided as an argument
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <laptop_monitor_name>")
        print(f"Example: {sys.argv[0]} eDP-1")
        sys.exit(1)

    try:
        main(sys.argv[1])
    except Exception as e:
        logger.error(e)
        sys.exit(1)
