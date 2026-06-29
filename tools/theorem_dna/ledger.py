from __future__ import annotations

from dataclasses import asdict, dataclass
from datetime import datetime, timezone
from typing import Any

from .hash import canonical_json, hash_text


@dataclass(frozen=True)
class LedgerEvent:
    event_type: str
    payload_hash: str
    previous_event_hash: str | None = None
    target: str | None = None
    actor: str | None = None
    timestamp: str | None = None

    def with_event_hash(self) -> dict[str, Any]:
        payload = asdict(self)
        if payload["timestamp"] is None:
            payload["timestamp"] = datetime.now(timezone.utc).isoformat()
        event_hash = hash_text(canonical_json(payload))
        payload["event_hash"] = event_hash
        return payload
