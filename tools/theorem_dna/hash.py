from __future__ import annotations

import hashlib
import json
from typing import Any, Iterable


def canonical_json(value: Any) -> str:
    return json.dumps(value, ensure_ascii=False, sort_keys=True, separators=(",", ":"))


def hash_text(text: str, algorithm: str = "sha256") -> str:
    if algorithm != "sha256":
        raise ValueError(f"unsupported algorithm: {algorithm}")
    digest = hashlib.sha256(text.encode("utf-8")).hexdigest()
    return f"sha256:{digest}"


def merkle_root(items: Iterable[str]) -> str:
    leaves = sorted(items)
    if not leaves:
        return hash_text("")
    layer = [hash_text(item) for item in leaves]
    while len(layer) > 1:
        next_layer = []
        for i in range(0, len(layer), 2):
            left = layer[i]
            right = layer[i + 1] if i + 1 < len(layer) else left
            next_layer.append(hash_text(left + right))
        layer = next_layer
    return f"merkle:{layer[0].split(':', 1)[1]}"
