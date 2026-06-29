# Roadmap

## M0: Repository Skeleton

- [x] Add repository structure
- [x] Add README
- [x] Add DNA specification
- [x] Add first deontic example

## M1: First Lean Proof

- [ ] Build Lean project in CI
- [ ] Verify `permission_from_obligation`
- [ ] Export verification result into a ledger event

## M2: Theorem DNA v0.1

- [ ] Stabilize JSON schema
- [ ] Define canonical hash format
- [ ] Implement Merkle root over dependencies
- [ ] Add environment DNA

## M3: Ledger v0.1

- [ ] Append-only event format
- [ ] Verify event hash chain
- [ ] Sign verification events

## M4: Isabelle/Rocq Mirrors

- [ ] Mirror minimal deontic example in Isabelle/HOL
- [ ] Mirror minimal deontic example in Rocq
- [ ] Add separate CI jobs

## M5: Corollary Generator

- [ ] Generate first corollary candidate
- [ ] Verify candidate in Lean
- [ ] Store accepted corollary DNA
