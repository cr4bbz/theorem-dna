from __future__ import annotations

from dataclasses import asdict, dataclass
from datetime import datetime, timezone
from typing import Any

from .hash import hash_json


@dataclass(frozen=True)
class LedgerEvent:
    event_type: str
    payload_hash: str
    previous_event_hash: str | None = None
    target: str | None = None
    actor: str | None = None
    timestamp: str | None = None
    metadata: dict[str, Any] | None = None

    def with_event_hash(self) -> dict[str, Any]:
        payload = asdict(self)
        payload["schema_version"] = "0.1.0"
        if payload["timestamp"] is None:
            payload["timestamp"] = datetime.now(timezone.utc).isoformat()
        payload = {key: value for key, value in payload.items() if value is not None}
        event_hash = hash_json(payload)
        payload["event_hash"] = event_hash
        return payload
