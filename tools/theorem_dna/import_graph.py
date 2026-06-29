from __future__ import annotations

from dataclasses import dataclass
from typing import Any


class ImportGraphError(ValueError):
    """Raised when a logic import graph is not well formed."""


@dataclass(frozen=True)
class ImportEdge:
    id: str
    source: str
    target: str


def validate_import_graph(graph: dict[str, Any]) -> None:
    """Validate semantic constraints not expressible in JSON Schema.

    JSON Schema checks shape. This function checks import-specific constraints:
    imports must refer to declared logics, each import must provide mappings, and
    the import graph must be acyclic.
    """

    logic_ids = [logic["id"] for logic in graph.get("logics", [])]
    duplicate_logics = sorted({logic for logic in logic_ids if logic_ids.count(logic) > 1})
    if duplicate_logics:
        raise ImportGraphError(
            f"duplicate logic id(s): {', '.join(duplicate_logics)}"
        )

    declared = set(logic_ids)
    edges: list[ImportEdge] = []
    for import_entry in graph.get("imports", []):
        import_id = import_entry["id"]
        source = import_entry["source"]
        target = import_entry["target"]
        if source not in declared:
            raise ImportGraphError(f"import {import_id} has unknown source {source}")
        if target not in declared:
            raise ImportGraphError(f"import {import_id} has unknown target {target}")
        if source == target:
            raise ImportGraphError(f"import {import_id} is a self-import")
        mappings = import_entry.get("mappings", [])
        if not mappings:
            raise ImportGraphError(f"import {import_id} has no symbol mappings")
        source_symbols = [mapping["source_symbol"] for mapping in mappings]
        duplicate_symbols = sorted(
            {symbol for symbol in source_symbols if source_symbols.count(symbol) > 1}
        )
        if duplicate_symbols:
            raise ImportGraphError(
                f"import {import_id} maps source symbol(s) more than once: "
                + ", ".join(duplicate_symbols)
            )
        edges.append(ImportEdge(import_id, source, target))

    adjacency: dict[str, list[ImportEdge]] = {logic_id: [] for logic_id in declared}
    for edge in edges:
        adjacency[edge.source].append(edge)

    visiting: set[str] = set()
    visited: set[str] = set()
    path: list[str] = []

    def visit(logic_id: str) -> None:
        if logic_id in visited:
            return
        if logic_id in visiting:
            cycle_start = path.index(logic_id)
            cycle = path[cycle_start:] + [logic_id]
            raise ImportGraphError("import cycle detected: " + " -> ".join(cycle))

        visiting.add(logic_id)
        path.append(logic_id)
        for edge in adjacency[logic_id]:
            visit(edge.target)
        path.pop()
        visiting.remove(logic_id)
        visited.add(logic_id)

    for logic_id in sorted(declared):
        visit(logic_id)
