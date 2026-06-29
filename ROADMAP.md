# Roadmap

## M0: Repository Skeleton

- [x] Add repository structure
- [x] Add README
- [x] Add DNA specification
- [x] Add first deontic example

## M1: First Lean Proof

- [ ] Build Lean project in CI
- [x] Verify `permission_from_obligation`
- [x] Export verification result into a ledger event

## M2: Theorem DNA v0.1

- [x] Stabilize JSON schema
- [x] Define canonical hash format
- [x] Implement Merkle root over dependencies
- [x] Add environment DNA

## M3: Ledger v0.1

- [x] Append-only event format
- [x] Verify event hash chain
- [ ] Sign verification events

## M4: Isabelle/Rocq Mirrors

- [x] Mirror minimal deontic example in Isabelle/HOL
- [x] Mirror minimal deontic example in Rocq
- [x] Add separate CI jobs

## M5: Corollary Generator

- [x] Generate first corollary candidate
- [x] Verify candidate in Lean
- [x] Store accepted corollary DNA
