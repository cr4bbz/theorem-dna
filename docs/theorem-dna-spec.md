# Theorem DNA Specification

Version 0.1 defines a deterministic identity record for each axiom, definition,
lemma, theorem, and corollary.

## Hash formats

- Content hashes use `sha256:` followed by 64 lowercase hexadecimal digits.
- Merkle roots use `merkle:` followed by 64 lowercase hexadecimal digits.
- JSON is encoded as UTF-8 with sorted object keys, no insignificant whitespace,
  and Unicode characters left unescaped.
- The v0.1 Merkle algorithm sorts leaves, preserves duplicates, domain-separates
  leaves and internal nodes, and duplicates an unpaired node.

## Layers

| Layer | Identity input |
|---|---|
| `source_dna` | Source path, line span, and exact source text |
| `informal_dna` | Lowercased, whitespace-normalized informal claim |
| `logic_dna` | Canonical logic-profile JSON |
| `formula_dna` | Whitespace-normalized formal formula |
| `context_dna` | Merkle root of imports, axioms, and definitions |
| `dependency_dna` | Merkle root of direct dependency identifiers |
| `proof_hash` | Exact proof artifact, stored per prover |
| `environment_hash` | Canonical prover environment, stored per prover |

Ledger identity is deliberately not embedded in a DNA record: ledger events
hash the record and link to the previous event. Embedding that event hash back
into the record would create a circular identity.

## Proof status

- `not_attempted`: no verifier result exists.
- `failed`: a verifier ran but did not accept the artifact.
- `checked`: verification succeeded. Statement, proof, environment, and
  verification-time hashes or values are then mandatory.

## Acceptance rule

A generated corollary may be marked as accepted only when at least one proof
entry has status `checked`.
