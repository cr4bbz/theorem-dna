from __future__ import annotations

import argparse
import json
from pathlib import Path

from theorem_dna.corollary import generate_contrapositive
from theorem_dna.generate import write_generated_dna
from theorem_dna.hash import hash_json
from theorem_dna.import_graph import validate_import_graph
from theorem_dna.ledger import LedgerEvent
from theorem_dna.report import write_verification_reports
from theorem_dna.signing import generate_keypair, sign_event, verify_signed_event
from theorem_dna.upstream_artifact import validate_upstream_artifact


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

    keygen = sub.add_parser("generate-signing-key")
    keygen.add_argument("private_key")
    keygen.add_argument("public_key")

    sign = sub.add_parser("sign-event")
    sign.add_argument("event")
    sign.add_argument("private_key")
    sign.add_argument("--key-id", required=True)
    sign.add_argument("--public-key", required=True)
    sign.add_argument("--output")

    verify = sub.add_parser("verify-event")
    verify.add_argument("event")
    verify.add_argument("public_key")

    import_graph = sub.add_parser("validate-import-graph")
    import_graph.add_argument("graph")

    upstream_artifact = sub.add_parser("validate-upstream-artifact")
    upstream_artifact.add_argument("artifact")
    upstream_artifact.add_argument("--root", default=".")

    render_report = sub.add_parser("render-verification-report")
    render_report.add_argument("report")
    render_report.add_argument("--output-dir", default="verification-reports")

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
    elif args.cmd == "generate-signing-key":
        generate_keypair(Path(args.private_key), Path(args.public_key))
    elif args.cmd == "sign-event":
        path = Path(args.event)
        value = json.loads(path.read_text(encoding="utf-8"))
        signed = sign_event(
            value,
            Path(args.private_key),
            args.key_id,
            args.public_key,
        )
        output = Path(args.output) if args.output else path
        output.write_text(
            json.dumps(signed, ensure_ascii=False, indent=2) + "\n",
            encoding="utf-8",
        )
    elif args.cmd == "verify-event":
        value = json.loads(Path(args.event).read_text(encoding="utf-8"))
        if not verify_signed_event(value, Path(args.public_key)):
            raise SystemExit("signature verification failed")
        print("signature valid")
    elif args.cmd == "validate-import-graph":
        value = json.loads(Path(args.graph).read_text(encoding="utf-8"))
        validate_import_graph(value)
        print("import graph valid")
    elif args.cmd == "validate-upstream-artifact":
        root = Path(args.root).resolve()
        value = json.loads(Path(args.artifact).read_text(encoding="utf-8"))
        validate_upstream_artifact(value, root)
        print("upstream artifact valid")
    elif args.cmd == "render-verification-report":
        value = json.loads(Path(args.report).read_text(encoding="utf-8-sig"))
        markdown_path, html_path = write_verification_reports(
            value, Path(args.output_dir)
        )
        print(f"markdown report: {markdown_path}")
        print(f"html report: {html_path}")


if __name__ == "__main__":
    main()
