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
  compatible with the obligations of a normative system.

Acceptance:

- definitions type-check in Lean;
- Propositions 2.6 and 4.2-4.4 are represented or explicitly scoped out;
- classical and at least one nonclassical instance are verified;
- generated DNA records every imported metalogical property.

### Actions, states, and bridging principles

Keep action obligations and state obligations as different types. Formalize
the bridge definitions and derive situation-specific norms without coercing
actions and propositions into one primitive.

Acceptance:

- separate action and state syntax;
- explicit bridge axioms with dependency DNA;
- one most-specific-obligation and one most-general-prohibition example.

### Importing logics

Formalize the smallest useful importing calculus: source/target signatures,
inherited axioms and rules, and derivation lifting. Prove soundness first;
concrete completeness is a separate deliverable.

Acceptance:

- imports are first-class versioned objects;
- cycles and missing mappings are rejected;
- a Lean proof covers soundness for one concrete import;
- cross-prover declarations retain the same import dependency graph.

## P1: stress tests and domain extensions

- Formalize ADeL0 before the stronger systems from *Generalizing Deontic
  Action Logic*.
- Encode the contrary-to-duty collapse result as a negative regression test,
  followed by both proposed repairs.
- Add the Hohfeldian system only after relational and agent-indexed claims are
  supported by the schema.

## Reference integration

The display-calculus paper already supplies a constructive Rocq
formalization. The project should register and verify that upstream artifact,
then reproduce one CPL cut-elimination/decidability example. Reimplementing
the entire framework would add thousands of lines without strengthening
Theorem DNA's core model.
