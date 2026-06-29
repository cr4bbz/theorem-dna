import json
from pathlib import Path

from theorem_dna.corollary import generate_contrapositive


ROOT = Path(__file__).resolve().parents[1]


def test_committed_corollary_matches_generator():
    manifest = json.loads(
        (
            ROOT
            / "data/corollaries/not-permitted-implies-not-obligatory.manifest.json"
        ).read_text(encoding="utf-8")
    )
    committed = json.loads(
        (
            ROOT / "data/corollaries/not-permitted-implies-not-obligatory.json"
        ).read_text(encoding="utf-8")
    )
    assert committed == generate_contrapositive(manifest)
    assert committed["status"] == "accepted"


def test_unverified_corollary_remains_a_candidate():
    manifest = {
        "id": "corollary:test",
        "rule": "contraposition",
        "premise_claim_id": "claim:test",
        "variable": "x",
        "antecedent": "P x",
        "consequent": "Q x",
        "informal": "Test.",
        "dna_file": "test.json",
        "verifications": [],
    }
    assert generate_contrapositive(manifest)["status"] == "candidate"
