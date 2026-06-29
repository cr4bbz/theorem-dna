from __future__ import annotations

import argparse
import json
from pathlib import Path

from theorem_dna.generate import write_generated_dna
from theorem_dna.hash import hash_json


def main() -> None:
    parser = argparse.ArgumentParser(description="Theorem DNA command line tools")
    sub = parser.add_subparsers(dest="cmd", required=True)

    h = sub.add_parser("hash-json")
    h.add_argument("path")

    generate = sub.add_parser("generate-dna")
    generate.add_argument("manifest")
    generate.add_argument("output")
    generate.add_argument("--root", default=".")

    args = parser.parse_args()

    if args.cmd == "hash-json":
        path = Path(args.path)
        value = json.loads(path.read_text(encoding="utf-8"))
        print(hash_json(value))
    elif args.cmd == "generate-dna":
        root = Path(args.root).resolve()
        write_generated_dna(root, Path(args.manifest).resolve(), Path(args.output).resolve())


if __name__ == "__main__":
    main()
