# Literature-backed Formalization Backlog

The source register in
`data/papers/foundational-formalization-candidates.json` is based on seven
locally reviewed papers. PDFs are not committed; DOI metadata and narrowly
defined formalization targets are.

## P0: foundational

### Selfextensional normative and permission systems

Start from the consequence relation and closure-operator presentation, then
formalize normative systems, output operations, and the four permission
families. This replaces the genesis axiom `Obl w -> Perm w` with an explicit
logic profile whose assumptions are visible in its DNA.

Current slice:

- `schema/logic_profile.schema.json` validates logic profiles as first-class
  project objects;
- `data/logic_profiles/selfextensional-normative-permission-v0.json` records
  the literature-backed profile, represented permission families, and scoped
  paper propositions;
- `provers/lean/TheoremDNA/LogicProfiles/Selfextensional.lean` type-checks the
  abstract consequence relation, closure operator, normative systems, simple
  output, the first two permission families, a Boolean/classical
  selfextensional instance, and a small three-valued preorder/nonclassical
  selfextensional instance;
- Proposition 2.6 is represented as a parameterized Lean theorem: under
  weakening of output, inconsistency-to-contrary entailment, and contrary
  inconsistency, conditional negative permission is the largest permission system
  compatible with the obligations of a normative system;
- Proposition 4.2 is represented as a parameterized Lean theorem equating the
  generalized compatibility definition of negative permission with absence of
  contrary obligation under the same explicit weakening and negation/consistency
  assumptions;
- Proposition 4.3 is represented as a Lean theorem: internal coherence entails
  almost inclusion of a normative system in its generalized negative permission
  system;
- Proposition 4.4 is represented as a Lean theorem: inclusion of normative
  systems is antitone for generalized negative permission.

Acceptance:

- definitions type-check in Lean;
- Propositions 2.6 and 4.2-4.4 are represented or explicitly scoped out;
- classical and at least one nonclassical instance are verified;
- generated DNA records every imported metalogical property.

### Actions, states, and bridging principles

Keep action obligations and state obligations as different types. Formalize
the bridge definitions and derive situation-specific norms without coercing
actions and propositions into one primitive.

Current slice:

- `data/logic_profiles/action-state-bridges-v0.json` records the
  literature-backed action/state bridge profile;
- `provers/lean/TheoremDNA/LogicProfiles/ActionState.lean` type-checks separate
  action-step and state predicate spaces, explicit realization/avoidance bridge
  principles, and candidate theorems for a most-specific obligation and a
  most-general prohibition;
- a contractor-style scenario derives a required safe-completion action from a
  required completion state plus a prohibition against unsafe work.

Acceptance:

- separate action and state syntax;
- explicit bridge axioms with dependency DNA;
- one most-specific-obligation and one most-general-prohibition example.

### Importing logics

Formalize the smallest useful importing calculus: source/target signatures,
inherited axioms and rules, and derivation lifting. Prove soundness first;
concrete completeness is a separate deliverable.

Current slice:

- `schema/import_graph.schema.json` and
  `data/imports/minimal-logic-import-v0.json` make imports first-class,
  versioned graph objects;
- `tools/theorem_dna/import_graph.py` rejects imports with unknown endpoints,
  missing mappings, duplicate source mappings, self-imports, and cycles;
- `provers/lean/TheoremDNA/LogicProfiles/Importing.lean` proves soundness of
  lifted derivations for a truth-preserving semantic import, plus one concrete
  minimal identity import.

Acceptance:

- imports are first-class versioned objects;
- cycles and missing mappings are rejected;
- a Lean proof covers soundness for one concrete import;
- cross-prover declarations retain the same import dependency graph.

## P1: stress tests and domain extensions

- Formalize ADeL0 before the stronger systems from *Generalizing Deontic
  Action Logic*.
  Current slice:
  - `data/logic_profiles/adel0-action-logic-v0.json` records the ADeL0
    action-deontic profile;
  - `provers/lean/TheoremDNA/LogicProfiles/ADeL0.lean` type-checks action
    terms, formula constructors, semantic frame conditions for D1-D4, O1-O5,
    and B1-B3, plus a tiny satisfiable model.
- Encode the contrary-to-duty collapse result as a negative regression test,
  followed by both proposed repairs.
  Current slice:
  - `data/logic_profiles/contrary-to-duty-regressions-v0.json` records the CTD
    collapse regression profile;
  - `provers/lean/TheoremDNA/LogicProfiles/ContraryToDuty.lean` type-checks
    mutual genericity, conditions 5(b), 5(d), 5(e), the collapse pattern from
    Theorem 1.2, and separated weak/strong repair packages corresponding to
    Theorems 2.1 and 2.2.
- Add the Hohfeldian system only after relational and agent-indexed claims are
  supported by the schema.
  Current slice:
  - `data/logic_profiles/hohfeldian-rights-v0.json` records a relational
    Hohfeldian rights profile based on Markovich's formal analysis;
  - `provers/lean/TheoremDNA/LogicProfiles/Hohfeld.lean` type-checks
    Agent-Agent-Act positions, explicit correlative laws for Claim-right/Duty,
    Privilege/No-claim, Power/Liability, and Immunity/Disability, opposite-pair
    consistency constraints, and a tiny land-parcel example.

## Reference integration

The display-calculus paper already supplies a constructive Rocq
formalization. The project should register and verify that upstream artifact,
then reproduce one CPL cut-elimination/decidability example. Reimplementing
the entire framework would add thousands of lines without strengthening
Theorem DNA's core model.

Current slice:

- `schema/upstream_artifact.schema.json` and
  `data/upstream_artifacts/display-calculus-rocq-v0.json` register the
  upstream Coq/Rocq 8.18.0 display-calculus proof environment described by the
  source paper, including the public documentation page, GitHub repository, and
  pinned main-branch revision;
- `tools/theorem_dna/upstream_artifact.py` validates cross-file constraints,
  including that registered artifacts cite known source papers and only pin
  revisions after a public locator is known;
- the CPL cut-elimination/decidability reproduction remains the next
  integration target after the upstream Rocq build is reproduced locally.
