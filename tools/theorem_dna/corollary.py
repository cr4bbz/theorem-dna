from __future__ import annotations

from typing import Any


def generate_contrapositive(manifest: dict[str, Any]) -> dict[str, Any]:
    if manifest["rule"] != "contraposition":
        raise ValueError(f"unsupported corollary rule: {manifest['rule']}")

    variable = manifest["variable"]
    antecedent = manifest["antecedent"]
    consequent = manifest["consequent"]
    verifications = manifest.get("verifications", [])
    accepted = any(item["status"] == "checked" for item in verifications)

    return {
        "schema_version": "0.1.0",
        "id": manifest["id"],
        "kind": "corollary",
        "status": "accepted" if accepted else "candidate",
        "generated_by": {
            "generator": "theorem-dna",
            "version": "0.1.0",
            "rule": "contraposition",
        },
        "premises": [manifest["premise_claim_id"]],
        "informal": manifest["informal"],
        "formula": f"∀ {variable}, ¬ {consequent} → ¬ {antecedent}",
        "verifications": verifications,
        "dna_file": manifest["dna_file"],
    }
