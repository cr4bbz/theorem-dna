```text
████████╗██╗  ██╗███████╗ ██████╗ ██████╗ ███████╗███╗   ███╗
╚══██╔══╝██║  ██║██╔════╝██╔═══██╗██╔══██╗██╔════╝████╗ ████║
   ██║   ███████║█████╗  ██║   ██║██████╔╝█████╗  ██╔████╔██║
   ██║   ██╔══██║██╔══╝  ██║   ██║██╔══██╗██╔══╝  ██║╚██╔╝██║
   ██║   ██║  ██║███████╗╚██████╔╝██║  ██║███████╗██║ ╚═╝ ██║
   ╚═╝   ╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝     ╚═╝

          D N A  ::  source-bound proof provenance
```

# Theorem DNA

A proof-oriented knowledge ledger for formal philosophy.

The goal of this project is to preserve philosophical source material, extract claims,
formalize them in proof assistants, verify them, and assign each axiom, definition,
lemma, theorem, corollary, and formalization a reproducible **Theorem DNA**.


░        ░░  ░░░░  ░░        ░░░      ░░░       ░░░        ░░  ░░░░  ░░░░░░░░       ░░░   ░░░  ░░░      ░░
▒▒▒▒  ▒▒▒▒▒  ▒▒▒▒  ▒▒  ▒▒▒▒▒▒▒▒  ▒▒▒▒  ▒▒  ▒▒▒▒  ▒▒  ▒▒▒▒▒▒▒▒   ▒▒   ▒▒▒▒▒▒▒▒  ▒▒▒▒  ▒▒    ▒▒  ▒▒  ▒▒▒▒  ▒
▓▓▓▓  ▓▓▓▓▓        ▓▓      ▓▓▓▓  ▓▓▓▓  ▓▓       ▓▓▓      ▓▓▓▓        ▓▓▓▓▓▓▓▓  ▓▓▓▓  ▓▓  ▓  ▓  ▓▓  ▓▓▓▓  ▓
████  █████  ████  ██  ████████  ████  ██  ███  ███  ████████  █  █  ████████  ████  ██  ██    ██        █
████  █████  ████  ██        ███      ███  ████  ██        ██  ████  ████████       ███  ███   ██  ████  █
                                                                                                          

## Core idea

A claim is not merely a sentence. It is a versioned object with:

- source provenance
- informal interpretation
- logic profile
- formal statement
- proof artifact
- dependencies
- verification environment
- ledger history

## Supported proof assistants

- Lean 4
- Isabelle/HOL
- Rocq

## First milestone

Formalize a minimal deontic example:

> Every obligation implies permission.

Then generate and verify a simple corollary.

## Repository map

```text
docs/       Conceptual architecture and specifications
schema/     JSON Schemas for DNA, claims, formalizations, ledger events
data/       Paper metadata, extracted claims, formalizations, corollaries
ledger/     Append-only event log
provers/    Lean 4, Isabelle/HOL, and Rocq proof projects
tools/      Python tools for hashing, canonicalization, and verification
tests/      Unit tests for schema and ledger logic
```

## Bootstrap

```bash
python -m pip install -e ".[test]"
python -m pytest
```

## One-click verification

On Windows, double-click `VERIFY.cmd` in the repository root:

```text
VERIFY.cmd
```

It bootstraps the Python environment, verifies schemas, hashes and signatures,
builds Lean, Isabelle and Rocq, checks the GitHub workflows and current pull
request, then prints one PASS/FAIL summary. The machine-readable result is
written to `verification-reports/last-report.json`.

PowerShell alternatives:

```powershell
.\scripts\verify.ps1 -Mode quick
.\scripts\verify.ps1 -Mode full
.\scripts\verify.ps1 -Mode full -SkipGitHub
```

Regenerate the genesis DNA record:

```bash
python tools/cli.py generate-dna \
  examples/deontic_obligation_permission/dna.manifest.json \
  examples/deontic_obligation_permission/dna.json
```

Generate the first derived corollary:

```bash
python tools/cli.py generate-corollary \
  data/corollaries/not-permitted-implies-not-obligatory.manifest.json \
  data/corollaries/not-permitted-implies-not-obligatory.json
```

Verify signed ledger events:

```bash
python tools/cli.py verify-event \
  ledger/events/genesis-proof-verified.json \
  keys/ledger-signing.pub.pem
```

The prioritized literature slices are documented in
`docs/formalization-backlog.md`; source PDFs are intentionally not committed.

Lean build:

```bash
cd provers/lean
lake build
```
