#!/usr/bin/env python

"""
This script checks whether a system reboot is needed (either becuase of a new
kernel or a new processor microcode) and prints the result in a waybar
format.
"""


import json
import subprocess


def print_output(text, tooltip, waybar_class):
    """Print a waybar-format output"""
    print(json.dumps({ "text": text,
                       "tooltip": tooltip,
                       "class": waybar_class }))


def run_needrestart():
    """Run needrestart and parse its output"""
    output = subprocess.check_output(["needrestart", "-wbk"],
                                     stderr=subprocess.DEVNULL).decode("utf-8")
    return dict(item.split(": ") for item in output[:-1].split("\n"))


def check_needrestart(data, prefix, message):
    """
    Check if the given item needs a restart, using its prefix in the
    needrestart data
    If a restart is needed, return the given message, formatted
    """
    sta = int(data[f"NEEDRESTART-{prefix}STA"])
    if sta == 0:
        raise RuntimeError(f"Unexpected {sta} value")
    if sta != 1:
        current = data[f"NEEDRESTART-{prefix}CUR"]
        new = data[f"NEEDRESTART-{prefix}EXP"]
        return message.format(current=current, new=new)


def main():
    try:
        needrestart_data = run_needrestart()
        kernel = check_needrestart(needrestart_data, "K",
            "New kernel version:\n{new}\nCurrent kernel version:\n{current}")
        microcode = check_needrestart(needrestart_data, "UC",
            "New microcode version:\n{new}\nCurrent microcode version:\n{current}")
        tooltip = "\n".join(line for line in [kernel, microcode] if line)
        if tooltip:
            tooltip = "A reboot is needed\n\n" + tooltip
            print_output("", tooltip, "warning")
        else:
            print_output("", "", "")

    except Exception as e:
        print_output("ERROR", f"need reboot has encountered an error:\n{e}",
                     "critical")


if __name__ == "__main__":
    main()
