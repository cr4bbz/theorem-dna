from __future__ import annotations

import json
import re
from pathlib import Path
from typing import Any

from .canonicalize import normalize_informal_claim
from .hash import hash_json, hash_text, merkle_root


SOURCE_SPAN_RE = re.compile(r"^(?P<path>.+)#L(?P<start>\d+)(?:-L(?P<end>\d+))?$")


def _read_json(path: Path) -> Any:
    return json.loads(path.read_text(encoding="utf-8"))


def _find_claim(claims: list[dict[str, Any]], claim_id: str) -> dict[str, Any]:
    for claim in claims:
        if claim["id"] == claim_id:
            return claim
    raise ValueError(f"claim not found: {claim_id}")


def _source_identity(root: Path, source_span: str) -> dict[str, Any]:
    match = SOURCE_SPAN_RE.fullmatch(source_span)
    if match is None:
        raise ValueError(f"invalid source span: {source_span}")
    relative_path = match.group("path")
    start = int(match.group("start"))
    end = int(match.group("end") or start)
    lines = (root / relative_path).read_text(encoding="utf-8").splitlines()
    if start < 1 or end < start or end > len(lines):
        raise ValueError(f"source span outside document: {source_span}")
    return {
        "document": relative_path,
        "start_line": start,
        "end_line": end,
        "text": "\n".join(lines[start - 1 : end]),
    }


def generate_dna(root: Path, manifest: dict[str, Any]) -> dict[str, Any]:
    claims_path = root / manifest["claim_file"]
    claims = _read_json(claims_path)
    claim = _find_claim(claims, manifest["claim_id"])
    logic_profile = _read_json(root / manifest["logic_profile_file"])

    formula = " ".join(manifest["formula"].split())
    proofs: dict[str, Any] = {}
    for prover, descriptor in manifest["proofs"].items():
        proof: dict[str, Any] = {"status": descriptor["status"]}
        if descriptor["status"] == "checked":
            proof_path = root / descriptor["file"]
            proof.update(
                {
                    "statement_hash": hash_text(formula),
                    "proof_hash": descriptor.get(
                        "proof_hash",
                        hash_text(proof_path.read_text(encoding="utf-8")),
                    ),
                    "environment_hash": hash_json(descriptor["environment"]),
                    "verified_at": descriptor["verified_at"],
                }
            )
        proofs[prover] = proof

    return {
        "schema_version": "0.1.0",
        "id": manifest["id"],
        "kind": manifest["kind"],
        "source_dna": hash_json(_source_identity(root, claim["source_span"])),
        "informal_dna": hash_text(normalize_informal_claim(claim["informal"])),
        "logic_dna": hash_json(logic_profile),
        "formula_dna": hash_text(formula),
        "context_dna": merkle_root(manifest.get("context", [])),
        "dependency_dna": merkle_root(manifest.get("dependencies", [])),
        "proofs": proofs,
    }


def write_generated_dna(root: Path, manifest_path: Path, output_path: Path) -> dict[str, Any]:
    manifest = _read_json(manifest_path)
    dna = generate_dna(root, manifest)
    output_path.write_text(json.dumps(dna, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    return dna
