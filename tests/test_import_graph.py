from __future__ import annotations

import copy
import json
from pathlib import Path

import pytest

from theorem_dna.import_graph import ImportGraphError, validate_import_graph


ROOT = Path(__file__).resolve().parents[1]


def load_valid_graph() -> dict:
    return json.loads(
        (ROOT / "data/imports/minimal-logic-import-v0.json").read_text(
            encoding="utf-8"
        )
    )


def test_valid_import_graph_passes():
    validate_import_graph(load_valid_graph())


def test_import_graph_rejects_missing_target():
    graph = load_valid_graph()
    graph["imports"][0]["target"] = "missing-target"

    with pytest.raises(ImportGraphError, match="unknown target"):
        validate_import_graph(graph)


def test_import_graph_rejects_missing_mappings():
    graph = load_valid_graph()
    graph["imports"][0]["mappings"] = []

    with pytest.raises(ImportGraphError, match="no symbol mappings"):
        validate_import_graph(graph)


def test_import_graph_rejects_cycles():
    graph = load_valid_graph()
    reverse = copy.deepcopy(graph["imports"][0])
    reverse["id"] = "target-to-source-v0"
    reverse["source"] = "target-minimal-v0"
    reverse["target"] = "source-minimal-v0"
    graph["imports"].append(reverse)

    with pytest.raises(ImportGraphError, match="cycle"):
        validate_import_graph(graph)
