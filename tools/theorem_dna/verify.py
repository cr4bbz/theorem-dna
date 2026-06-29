from __future__ import annotations

import subprocess
from pathlib import Path


def run_command(command: list[str], cwd: Path) -> tuple[int, str, str]:
    completed = subprocess.run(command, cwd=cwd, text=True, capture_output=True)
    return completed.returncode, completed.stdout, completed.stderr
