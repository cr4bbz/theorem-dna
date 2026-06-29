from __future__ import annotations

import argparse
import json
from pathlib import Path

from theorem_dna.hash import canonical_json, hash_text


def main() -> None:
    parser = argparse.ArgumentParser(description="Theorem DNA command line tools")
    sub = parser.add_subparsers(dest="cmd", required=True)

    h = sub.add_parser("hash-json")
    h.add_argument("path")

    args = parser.parse_args()

    if args.cmd == "hash-json":
        path = Path(args.path)
        value = json.loads(path.read_text(encoding="utf-8"))
        print(hash_text(canonical_json(value)))


if __name__ == "__main__":
    main()
