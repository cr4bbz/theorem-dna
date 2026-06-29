from __future__ import annotations

from pathlib import Path
from typing import Any

import json


class UpstreamArtifactError(ValueError):
    """Raised when an upstream formalization artifact registration is inconsistent."""


def validate_upstream_artifact(artifact: dict[str, Any], root: Path) -> None:
    """Validate cross-file constraints for upstream artifact registrations."""

    paper_ids = {
        paper["id"]
        for paper in json.loads(
            (root / "data/papers/foundational-formalization-candidates.json").read_text(
                encoding="utf-8"
            )
        )
    }
    source_paper = artifact["source_paper"]
    if source_paper not in paper_ids:
        raise UpstreamArtifactError(
            f"source paper {source_paper} is not registered"
        )

    locator = artifact["locator"]
    if locator["status"] == "located" and not locator.get("url"):
        raise UpstreamArtifactError("located upstream artifact requires a url")
    if locator["status"] == "pending" and locator.get("revision"):
        raise UpstreamArtifactError("pending upstream artifact cannot pin a revision")

    verification = artifact["verification"]
    check_statuses = {check["status"] for check in verification.get("checks", [])}
    if verification["status"] == "local-checkout-verified" and "pending" in check_statuses:
        raise UpstreamArtifactError(
            "local-checkout-verified artifact cannot have pending checks"
        )
    if verification["status"] == "registered" and "failed" in check_statuses:
        raise UpstreamArtifactError("registered artifact cannot include failed checks")

    claim_ids = [claim["id"] for claim in artifact.get("claims", [])]
    duplicate_claims = sorted(
        {claim_id for claim_id in claim_ids if claim_ids.count(claim_id) > 1}
    )
    if duplicate_claims:
        raise UpstreamArtifactError(
            "duplicate artifact claim id(s): " + ", ".join(duplicate_claims)
        )

    target_ids = [target["id"] for target in artifact.get("integration_targets", [])]
    duplicate_targets = sorted(
        {target_id for target_id in target_ids if target_ids.count(target_id) > 1}
    )
    if duplicate_targets:
        raise UpstreamArtifactError(
            "duplicate integration target id(s): " + ", ".join(duplicate_targets)
        )
