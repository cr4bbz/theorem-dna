# Architecture

```text
Source Layer
  Original documents, source spans, quotations, notation

Semantic Layer
  Claims, concepts, logic profiles, interpretation decisions

Formal Layer
  Lean 4, Isabelle/HOL, Rocq formalizations

Ledger Layer
  Hashes, Merkle DAGs, verification runs, signatures
```

## Vertical slice

```text
source.md
  ↓
claims.json
  ↓
Lean/Isabelle/Rocq formalization
  ↓
Verification run
  ↓
Theorem DNA
  ↓
Ledger event
  ↓
Accepted corollary
```
