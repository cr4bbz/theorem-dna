import json
from pathlib import Path

import jsonschema


ROOT = Path(__file__).resolve().parents[1]


def test_example_dna_matches_schema():
    schema = json.loads((ROOT / "schema/theorem_dna.schema.json").read_text())
    value = json.loads((ROOT / "examples/deontic_obligation_permission/dna.json").read_text())
    jsonschema.validate(value, schema)
