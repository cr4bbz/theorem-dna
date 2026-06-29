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
