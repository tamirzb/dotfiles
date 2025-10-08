"""
A Python daemon that continuously monitors Arch and AUR package updates.
Writes the output to $XDG_RUNTIME_DIR for waybar consumption.
"""

import asyncio

from .arch_updates import UpdatesMonitor


if __name__ == "__main__":
    monitor = UpdatesMonitor()
    asyncio.run(monitor.run())
