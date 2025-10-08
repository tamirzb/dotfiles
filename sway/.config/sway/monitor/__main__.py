"""
A Python daemon that continuously monitors:
- Internet connection
- Arch and AUR package updates
Writes the output to $XDG_RUNTIME_DIR for waybar consumption.
"""


import asyncio

from .arch_updates import UpdatesMonitor
from .internet import InternetMonitor


async def main():
    internet = InternetMonitor()
    updates = UpdatesMonitor(internet)
    await asyncio.gather(internet.run(), updates.run())


if __name__ == "__main__":
    asyncio.run(main())
