from __future__ import annotations

import argparse
import json
from pathlib import Path

from theorem_dna.corollary import generate_contrapositive
from theorem_dna.generate import write_generated_dna
from theorem_dna.hash import hash_json
from theorem_dna.ledger import LedgerEvent


def main() -> None:
    parser = argparse.ArgumentParser(description="Theorem DNA command line tools")
    sub = parser.add_subparsers(dest="cmd", required=True)

    h = sub.add_parser("hash-json")
    h.add_argument("path")

    generate = sub.add_parser("generate-dna")
    generate.add_argument("manifest")
    generate.add_argument("output")
    generate.add_argument("--root", default=".")

    corollary = sub.add_parser("generate-corollary")
    corollary.add_argument("manifest")
    corollary.add_argument("output")

    event = sub.add_parser("ledger-event")
    event.add_argument("event_type")
    event.add_argument("payload")
    event.add_argument("output")
    event.add_argument("--target", required=True)
    event.add_argument("--actor", required=True)
    event.add_argument("--timestamp", required=True)
    event.add_argument("--previous-event")
    event.add_argument("--metadata")

    args = parser.parse_args()

    if args.cmd == "hash-json":
        path = Path(args.path)
        value = json.loads(path.read_text(encoding="utf-8"))
        print(hash_json(value))
    elif args.cmd == "generate-dna":
        root = Path(args.root).resolve()
        write_generated_dna(root, Path(args.manifest).resolve(), Path(args.output).resolve())
    elif args.cmd == "generate-corollary":
        manifest = json.loads(Path(args.manifest).read_text(encoding="utf-8"))
        value = generate_contrapositive(manifest)
        Path(args.output).write_text(
            json.dumps(value, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
        )
    elif args.cmd == "ledger-event":
        payload = json.loads(Path(args.payload).read_text(encoding="utf-8"))
        previous_hash = None
        if args.previous_event:
            previous = json.loads(
                Path(args.previous_event).read_text(encoding="utf-8")
            )
            previous_hash = previous["event_hash"]
        metadata = (
            json.loads(Path(args.metadata).read_text(encoding="utf-8"))
            if args.metadata
            else None
        )
        value = LedgerEvent(
            event_type=args.event_type,
            payload_hash=hash_json(payload),
            previous_event_hash=previous_hash,
            target=args.target,
            actor=args.actor,
            timestamp=args.timestamp,
            metadata=metadata,
        ).with_event_hash()
        Path(args.output).write_text(
            json.dumps(value, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
        )


if __name__ == "__main__":
    main()
