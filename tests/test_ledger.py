import json
from pathlib import Path

from theorem_dna.hash import hash_json


ROOT = Path(__file__).resolve().parents[1]
EVENTS = [
    ROOT / "ledger/events/genesis.json",
    ROOT / "ledger/events/genesis-proof-verified.json",
    ROOT / "ledger/events/not-permitted-implies-not-obligatory-accepted.json",
]


def test_event_hashes_and_chain_are_valid():
    previous_hash = None
    for path in EVENTS:
        event = json.loads(path.read_text(encoding="utf-8"))
        event_hash = event.pop("event_hash")
        assert event_hash == hash_json(event)
        assert event.get("previous_event_hash") == previous_hash
        previous_hash = event_hash


def test_event_payload_hashes_match_payloads():
    payloads = [
        ROOT / "ledger/payloads/genesis.json",
        ROOT / "examples/deontic_obligation_permission/dna.json",
        ROOT / "data/corollaries/not-permitted-implies-not-obligatory.dna.json",
    ]
    for event_path, payload_path in zip(EVENTS, payloads, strict=True):
        event = json.loads(event_path.read_text(encoding="utf-8"))
        payload = json.loads(payload_path.read_text(encoding="utf-8"))
        assert event["payload_hash"] == hash_json(payload)
