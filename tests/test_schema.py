import json
from pathlib import Path

import jsonschema
import pytest
from jsonschema import FormatChecker


ROOT = Path(__file__).resolve().parents[1]


def test_example_dna_matches_schema():
    schema = json.loads(
        (ROOT / "schema/theorem_dna.schema.json").read_text(encoding="utf-8")
    )
    value = json.loads(
        (ROOT / "examples/deontic_obligation_permission/dna.json").read_text(
            encoding="utf-8"
        )
    )
    jsonschema.validate(value, schema, format_checker=FormatChecker())


def test_checked_proof_requires_verification_metadata():
    schema = json.loads(
        (ROOT / "schema/theorem_dna.schema.json").read_text(encoding="utf-8")
    )
    value = json.loads(
        (ROOT / "examples/deontic_obligation_permission/dna.json").read_text(
            encoding="utf-8"
        )
    )
    value["proofs"]["lean4"] = {"status": "checked"}

    with pytest.raises(jsonschema.ValidationError):
        jsonschema.validate(value, schema, format_checker=FormatChecker())


def test_claims_match_schema():
    schema = json.loads((ROOT / "schema/claim.schema.json").read_text(encoding="utf-8"))
    claims = json.loads(
        (ROOT / "examples/deontic_obligation_permission/claims.json").read_text(
            encoding="utf-8"
        )
    )
    for claim in claims:
        jsonschema.validate(claim, schema, format_checker=FormatChecker())


def test_formalizations_match_schema():
    schema = json.loads(
        (ROOT / "schema/formalization.schema.json").read_text(encoding="utf-8")
    )
    for path in (ROOT / "data/formalizations").glob("*.json"):
        value = json.loads(path.read_text(encoding="utf-8"))
        jsonschema.validate(value, schema, format_checker=FormatChecker())


def test_corollaries_match_schema():
    schema = json.loads(
        (ROOT / "schema/corollary.schema.json").read_text(encoding="utf-8")
    )
    for path in (ROOT / "data/corollaries").glob("*.json"):
        if ".manifest." in path.name or ".dna." in path.name:
            continue
        value = json.loads(path.read_text(encoding="utf-8"))
        jsonschema.validate(value, schema, format_checker=FormatChecker())


def test_ledger_events_match_schema():
    schema = json.loads(
        (ROOT / "schema/ledger_event.schema.json").read_text(encoding="utf-8")
    )
    for path in (ROOT / "ledger/events").glob("*.json"):
        value = json.loads(path.read_text(encoding="utf-8"))
        jsonschema.validate(value, schema, format_checker=FormatChecker())


def test_foundational_papers_match_schema():
    schema = json.loads(
        (ROOT / "schema/paper.schema.json").read_text(encoding="utf-8")
    )
    papers = json.loads(
        (
            ROOT / "data/papers/foundational-formalization-candidates.json"
        ).read_text(encoding="utf-8")
    )
    for paper in papers:
        jsonschema.validate(paper, schema, format_checker=FormatChecker())


def test_logic_profiles_match_schema():
    schema = json.loads(
        (ROOT / "schema/logic_profile.schema.json").read_text(encoding="utf-8")
    )
    for path in (ROOT / "data/logic_profiles").glob("*.json"):
        value = json.loads(path.read_text(encoding="utf-8"))
        jsonschema.validate(value, schema, format_checker=FormatChecker())


def test_import_graphs_match_schema():
    schema = json.loads(
        (ROOT / "schema/import_graph.schema.json").read_text(encoding="utf-8")
    )
    for path in (ROOT / "data/imports").glob("*.json"):
        value = json.loads(path.read_text(encoding="utf-8"))
        jsonschema.validate(value, schema, format_checker=FormatChecker())


def test_upstream_artifacts_match_schema():
    schema = json.loads(
        (ROOT / "schema/upstream_artifact.schema.json").read_text(encoding="utf-8")
    )
    for path in (ROOT / "data/upstream_artifacts").glob("*.json"):
        value = json.loads(path.read_text(encoding="utf-8"))
        jsonschema.validate(value, schema, format_checker=FormatChecker())
