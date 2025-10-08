import json
import os
import sys
from pathlib import Path


class BaseMonitor:
    def __init__(self, json_filename: str):
        xdg_runtime_dir = Path(os.environ["XDG_RUNTIME_DIR"])
        self.output_file = xdg_runtime_dir / json_filename

    def log(self, *args, **kwargs):
        class_name = self.__class__.__name__
        print(f"{class_name}:", *args, **kwargs, flush=True)

    def write_json(self, text="", tooltip="", class_name=""):
        data = {"text": text, "tooltip": tooltip, "class": class_name}

        try:
            with open(self.output_file, "w", encoding="utf-8") as f:
                json.dump(data, f, ensure_ascii=False)
                f.write("\n")
        except Exception as e:
            self.log(f"Unexpected error while writing json file: {e}")
            sys.exit(1)
