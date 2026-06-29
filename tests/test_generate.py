from pathlib import Path

from theorem_dna.generate import generate_dna


ROOT = Path(__file__).resolve().parents[1]


def test_example_generation_is_deterministic():
    import json

    manifest = json.loads(
        (ROOT / "examples/deontic_obligation_permission/dna.manifest.json").read_text()
    )
    assert generate_dna(ROOT, manifest) == generate_dna(ROOT, manifest)


def test_example_generation_contains_real_hashes():
    import json

    manifest = json.loads(
        (ROOT / "examples/deontic_obligation_permission/dna.manifest.json").read_text()
    )
    dna = generate_dna(ROOT, manifest)
    assert dna["source_dna"].startswith("sha256:")
    assert "TODO" not in str(dna)


def test_committed_example_matches_generator():
    import json

    manifest = json.loads(
        (ROOT / "examples/deontic_obligation_permission/dna.manifest.json").read_text()
    )
    committed = json.loads(
        (ROOT / "examples/deontic_obligation_permission/dna.json").read_text()
    )
    assert committed == generate_dna(ROOT, manifest)
