# Roadmap

## M0: Repository Skeleton

- [x] Add repository structure
- [x] Add README
- [x] Add DNA specification
- [x] Add first deontic example

## M1: First Lean Proof

- [x] Build Lean project in CI
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
- [x] Sign verification events

## M4: Isabelle/Rocq Mirrors

- [x] Mirror minimal deontic example in Isabelle/HOL
- [x] Mirror minimal deontic example in Rocq
- [x] Add separate CI jobs

## M5: Corollary Generator

- [x] Generate first corollary candidate
- [x] Verify candidate in Lean
- [x] Store accepted corollary DNA

## M6: Literature-backed Logic Profiles

- [x] Register foundational papers and formalization slices
- [x] Add first-class logic profile schema
- [x] Add selfextensional normative/permission draft profile
- [x] Type-check abstract Lean core for consequence, closure, norms, and negative permissions
- [x] Verify classical instance for selfextensional normative and permission systems
- [x] Verify at least one nonclassical instance for selfextensional normative and permission systems
- [x] Represent Proposition 2.6 as a parameterized Lean theorem
- [x] Represent Proposition 4.2 as a parameterized Lean theorem
- [x] Represent Proposition 4.3 as a Lean theorem
- [x] Represent Proposition 4.4 as a Lean theorem
- [x] Separate action and state deontic languages with bridge principles
- [x] Add a sound logic-import calculus
- [x] Add ADeL0 as the first deontic action logic profile
- [x] Encode contrary-to-duty collapse and repair regression tests
- [x] Add relational Hohfeldian rights after agent-indexed claims
- [ ] Register the upstream Rocq display-calculus artifact
