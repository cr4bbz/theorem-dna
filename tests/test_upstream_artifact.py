from __future__ import annotations

import copy
import json
from pathlib import Path

import pytest

from theorem_dna.upstream_artifact import (
    UpstreamArtifactError,
    validate_upstream_artifact,
)


ROOT = Path(__file__).resolve().parents[1]


def load_valid_artifact() -> dict:
    return json.loads(
        (ROOT / "data/upstream_artifacts/display-calculus-rocq-v0.json").read_text(
            encoding="utf-8"
        )
    )


def test_valid_upstream_artifact_passes():
    validate_upstream_artifact(load_valid_artifact(), ROOT)


def test_upstream_artifact_requires_registered_source_paper():
    artifact = load_valid_artifact()
    artifact["source_paper"] = "doi:10.0000/missing"

    with pytest.raises(UpstreamArtifactError, match="source paper"):
        validate_upstream_artifact(artifact, ROOT)


def test_located_upstream_artifact_requires_url():
    artifact = load_valid_artifact()
    artifact["locator"]["status"] = "located"

    with pytest.raises(UpstreamArtifactError, match="requires a url"):
        validate_upstream_artifact(artifact, ROOT)


def test_pending_upstream_artifact_cannot_pin_revision():
    artifact = load_valid_artifact()
    artifact["locator"]["revision"] = "abc123"

    with pytest.raises(UpstreamArtifactError, match="cannot pin a revision"):
        validate_upstream_artifact(artifact, ROOT)


def test_duplicate_claim_ids_are_rejected():
    artifact = load_valid_artifact()
    artifact["claims"].append(copy.deepcopy(artifact["claims"][0]))

    with pytest.raises(UpstreamArtifactError, match="duplicate artifact claim"):
        validate_upstream_artifact(artifact, ROOT)
