from __future__ import annotations

import copy
import json
from pathlib import Path

import pytest

from theorem_dna.milestone import (
    MilestoneError,
    lean_module_to_path,
    validate_milestone,
)


ROOT = Path(__file__).resolve().parents[1]


def load_valid_milestone() -> dict:
    return json.loads(
        (ROOT / "data/milestones/p0-claim-corpus-v0.1.json").read_text(
            encoding="utf-8"
        )
    )


def test_valid_milestone_passes():
    validate_milestone(load_valid_milestone(), ROOT)


def test_all_milestones_pass_cross_file_validation():
    for path in (ROOT / "data/milestones").glob("*.json"):
        validate_milestone(json.loads(path.read_text(encoding="utf-8")), ROOT)


def test_lean_module_resolves_to_source_file():
    assert lean_module_to_path(
        ROOT, "TheoremDNA.LogicProfiles.ContraryToDuty"
    ) == ROOT / "provers/lean/TheoremDNA/LogicProfiles/ContraryToDuty.lean"


def test_milestone_rejects_unknown_paper():
    milestone = load_valid_milestone()
    milestone["slices"][0]["paper"] = "doi:10.0000/missing"

    with pytest.raises(MilestoneError, match="unknown paper"):
        validate_milestone(milestone, ROOT)


def test_milestone_rejects_missing_referenced_file():
    milestone = load_valid_milestone()
    milestone["slices"][0]["logic_profile_file"] = "data/logic_profiles/missing.json"

    with pytest.raises(MilestoneError, match="missing logic_profile_file"):
        validate_milestone(milestone, ROOT)


def test_milestone_rejects_missing_lean_module():
    milestone = load_valid_milestone()
    milestone["slices"][0]["lean_module"] = "TheoremDNA.LogicProfiles.Missing"

    with pytest.raises(MilestoneError, match="missing lean_module"):
        validate_milestone(milestone, ROOT)


def test_milestone_rejects_duplicate_slice_slugs():
    milestone = load_valid_milestone()
    milestone["slices"].append(copy.deepcopy(milestone["slices"][0]))

    with pytest.raises(MilestoneError, match="duplicate milestone slice slug"):
        validate_milestone(milestone, ROOT)


def test_upstream_registration_requires_upstream_artifact_kind():
    milestone = load_valid_milestone()
    milestone["slices"][-1]["artifact_kind"] = "logic_profile"

    with pytest.raises(MilestoneError, match="upstream_registration"):
        validate_milestone(milestone, ROOT)


def test_external_registered_requires_upstream_registration():
    milestone = load_valid_milestone()
    milestone["slices"][-1]["source_relation"] = "interpretive_note"

    with pytest.raises(MilestoneError, match="external_registered"):
        validate_milestone(milestone, ROOT)


def test_scenario_regression_cannot_be_external_registration():
    milestone = load_valid_milestone()
    milestone["slices"][1]["status"] = "external_registered"

    with pytest.raises(MilestoneError, match="scenario regression"):
        validate_milestone(milestone, ROOT)
