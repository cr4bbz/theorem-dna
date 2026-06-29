from __future__ import annotations

import json
from pathlib import Path
from typing import Any


class MilestoneError(ValueError):
    """Raised when a milestone file is structurally valid but inconsistent."""


FILE_REFERENCE_KEYS = (
    "logic_profile_file",
    "import_graph_file",
    "upstream_artifact_file",
)


def lean_module_to_path(root: Path, module: str) -> Path:
    """Resolve a Lean module name to its expected source path."""

    parts = module.split(".")
    if not parts or parts[0] != "TheoremDNA":
        raise MilestoneError(
            f"lean_module {module} must start with TheoremDNA"
        )
    return root / "provers/lean" / Path(*parts).with_suffix(".lean")


def validate_milestone(milestone: dict[str, Any], root: Path) -> None:
    """Validate cross-file constraints for a milestone record.

    JSON Schema validates shape. This function checks the project-specific
    provenance links that make a milestone useful as machine-readable status:
    registered source papers, referenced files, Lean module paths, and basic
    source-relation/status consistency.
    """

    paper_ids = {
        paper["id"]
        for paper in json.loads(
            (root / "data/papers/foundational-formalization-candidates.json").read_text(
                encoding="utf-8"
            )
        )
    }

    seen_slugs: set[str] = set()
    for slice_entry in milestone.get("slices", []):
        slug = slice_entry["slug"]
        if slug in seen_slugs:
            raise MilestoneError(f"duplicate milestone slice slug: {slug}")
        seen_slugs.add(slug)

        paper = slice_entry["paper"]
        if paper not in paper_ids:
            raise MilestoneError(f"slice {slug} references unknown paper {paper}")

        for key in FILE_REFERENCE_KEYS:
            if key in slice_entry:
                path = root / slice_entry[key]
                if not path.exists():
                    raise MilestoneError(
                        f"slice {slug} references missing {key}: {slice_entry[key]}"
                    )

        if "lean_module" in slice_entry:
            lean_path = lean_module_to_path(root, slice_entry["lean_module"])
            if not lean_path.exists():
                raise MilestoneError(
                    f"slice {slug} references missing lean_module "
                    f"{slice_entry['lean_module']} at {lean_path}"
                )

        source_relation = slice_entry["source_relation"]
        artifact_kind = slice_entry["artifact_kind"]
        status = slice_entry["status"]

        if source_relation == "upstream_registration" and artifact_kind != "upstream_artifact":
            raise MilestoneError(
                f"slice {slug} uses upstream_registration with artifact_kind "
                f"{artifact_kind}"
            )

        if source_relation == "scenario_regression" and status == "external_registered":
            raise MilestoneError(
                f"slice {slug} marks a scenario regression as externally registered"
            )

        if status == "external_registered" and source_relation != "upstream_registration":
            raise MilestoneError(
                f"slice {slug} uses external_registered without upstream_registration"
            )
