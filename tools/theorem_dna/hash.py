from __future__ import annotations

import hashlib
import json
from typing import Any, Iterable


def canonical_json(value: Any) -> str:
    """Serialize the JSON subset used by Theorem DNA v0.1 deterministically."""
    return json.dumps(value, ensure_ascii=False, sort_keys=True, separators=(",", ":"))


def hash_text(text: str, algorithm: str = "sha256") -> str:
    if algorithm != "sha256":
        raise ValueError(f"unsupported algorithm: {algorithm}")
    digest = hashlib.sha256(text.encode("utf-8")).hexdigest()
    return f"sha256:{digest}"


def hash_json(value: Any) -> str:
    return hash_text(canonical_json(value))


def merkle_root(items: Iterable[str]) -> str:
    """Return the order-independent Theorem DNA v0.1 Merkle root.

    Leaves and internal nodes use domain separation. Duplicate leaves remain
    significant; sorting only removes input-order dependence.
    """
    leaves = sorted(items)
    if not leaves:
        empty_digest = hash_text("empty\0").split(":", 1)[1]
        return f"merkle:{empty_digest}"
    layer = [hash_text(f"leaf\0{item}") for item in leaves]
    while len(layer) > 1:
        next_layer = []
        for i in range(0, len(layer), 2):
            left = layer[i]
            right = layer[i + 1] if i + 1 < len(layer) else left
            next_layer.append(hash_text(f"node\0{left}\0{right}"))
        layer = next_layer
    return f"merkle:{layer[0].split(':', 1)[1]}"
