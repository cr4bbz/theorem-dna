# Theorem DNA Specification

Each claim, axiom, definition, lemma, theorem, and corollary has a layered identity record.

## Layers

- `source_dna`: source span and source document identity
- `informal_dna`: normalized informal claim identity
- `logic_dna`: logic profile identity
- `formula_dna`: canonical formal formula identity
- `context_dna`: imports, axioms, and definitions
- `proof_dna`: proof script or proof artifact
- `dependency_dna`: dependency graph identity
- `environment_dna`: prover version and build environment
- `ledger_dna`: event history identity

## Acceptance rule

A generated corollary is accepted only after successful verification by at least one configured proof assistant.
