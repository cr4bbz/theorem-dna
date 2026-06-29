from __future__ import annotations

import base64
from copy import deepcopy
from pathlib import Path
from typing import Any

from cryptography.exceptions import InvalidSignature
from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.primitives.asymmetric.ed25519 import (
    Ed25519PrivateKey,
    Ed25519PublicKey,
)

from .hash import hash_bytes, hash_json


def generate_keypair(private_path: Path, public_path: Path) -> None:
    private_key = Ed25519PrivateKey.generate()
    private_path.parent.mkdir(parents=True, exist_ok=True)
    public_path.parent.mkdir(parents=True, exist_ok=True)
    private_path.write_bytes(
        private_key.private_bytes(
            encoding=serialization.Encoding.PEM,
            format=serialization.PrivateFormat.PKCS8,
            encryption_algorithm=serialization.NoEncryption(),
        )
    )
    public_path.write_bytes(
        private_key.public_key().public_bytes(
            encoding=serialization.Encoding.PEM,
            format=serialization.PublicFormat.SubjectPublicKeyInfo,
        )
    )


def _unsigned_event(event: dict[str, Any]) -> dict[str, Any]:
    unsigned = deepcopy(event)
    unsigned.pop("event_hash", None)
    unsigned.pop("signature", None)
    return unsigned


def verify_event_hash(event: dict[str, Any]) -> bool:
    return event.get("event_hash") == hash_json(_unsigned_event(event))


def sign_event(
    event: dict[str, Any], private_key_path: Path, key_id: str, public_key_path: str
) -> dict[str, Any]:
    if not verify_event_hash(event):
        raise ValueError("event_hash does not match the canonical unsigned event")
    private_key = serialization.load_pem_private_key(
        private_key_path.read_bytes(), password=None
    )
    if not isinstance(private_key, Ed25519PrivateKey):
        raise TypeError("expected an Ed25519 private key")
    public_der = private_key.public_key().public_bytes(
        encoding=serialization.Encoding.DER,
        format=serialization.PublicFormat.SubjectPublicKeyInfo,
    )
    signed_hash = event["event_hash"]
    signature = private_key.sign(signed_hash.encode("utf-8"))
    result = deepcopy(event)
    result["signature"] = {
        "algorithm": "ed25519",
        "key_id": key_id,
        "public_key": public_key_path,
        "public_key_hash": hash_bytes(public_der),
        "signed_hash": signed_hash,
        "value": base64.b64encode(signature).decode("ascii"),
    }
    return result


def verify_signed_event(event: dict[str, Any], public_key_path: Path) -> bool:
    signature_data = event.get("signature")
    if signature_data is None or signature_data["algorithm"] != "ed25519":
        return False
    if not verify_event_hash(event):
        return False
    if signature_data["signed_hash"] != event["event_hash"]:
        return False
    public_key = serialization.load_pem_public_key(public_key_path.read_bytes())
    if not isinstance(public_key, Ed25519PublicKey):
        return False
    public_der = public_key.public_bytes(
        encoding=serialization.Encoding.DER,
        format=serialization.PublicFormat.SubjectPublicKeyInfo,
    )
    if signature_data["public_key_hash"] != hash_bytes(public_der):
        return False
    try:
        public_key.verify(
            base64.b64decode(signature_data["value"]),
            event["event_hash"].encode("utf-8"),
        )
    except (InvalidSignature, ValueError):
        return False
    return True
