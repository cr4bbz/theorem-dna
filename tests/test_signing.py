import json
from pathlib import Path

from theorem_dna.ledger import LedgerEvent
from theorem_dna.signing import (
    generate_keypair,
    sign_event,
    verify_signed_event,
)


def test_ed25519_event_signature_detects_tampering(tmp_path: Path):
    private_key = tmp_path / "private.pem"
    public_key = tmp_path / "public.pem"
    generate_keypair(private_key, public_key)
    event = LedgerEvent(
        event_type="PROOF_VERIFIED",
        payload_hash="sha256:" + "a" * 64,
        target="claim:test",
        actor="test",
        timestamp="2026-06-29T00:00:00Z",
    ).with_event_hash()
    signed = sign_event(event, private_key, "test-key", "keys/test.pub.pem")
    assert verify_signed_event(signed, public_key)

    tampered = json.loads(json.dumps(signed))
    tampered["payload_hash"] = "sha256:" + "b" * 64
    assert not verify_signed_event(tampered, public_key)
