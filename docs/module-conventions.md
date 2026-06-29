# Module conventions

The repository now has enough formal material that names need to carry
provenance, not just implementation convenience. These conventions keep the
Lean/Rocq/Isabelle modules, JSON metadata, and future UI/API views aligned.

## Lean namespace layout

`TheoremDNA.LogicProfiles.*` contains abstract logic profiles and
paper-sourced model slices. A module in this namespace may be:

- an abstract core used by later profiles, such as selfextensional consequence
  relations;
- a paper slice that represents selected definitions, frame conditions, or
  propositions from one source;
- a regression profile, when the point is to preserve a known failure/collapse
  pattern and its repairs.

Do not move current modules just to create a tidier tree. Prefer documenting the
role first, then introduce domain folders only when several files genuinely need
their own internal structure.

## Domain folders

Future domain folders such as `TheoremDNA.CTD.*`, `TheoremDNA.Hohfeld.*`, or
`TheoremDNA.ActionState.*` should be used when a topic grows beyond a single
logic-profile slice. They may re-export, refine, or instantiate
`LogicProfiles.*` modules, but should not silently replace the profile metadata
in `data/logic_profiles/`.

## Source relation labels

Metadata should distinguish how a formal object relates to a source:

- `direct_formalization`: close formalization of a named source definition,
  proposition, theorem, or construction;
- `parameterized_representation`: an abstract theorem representing the source
  result under explicit assumptions;
- `scenario_regression`: an illustrative or test scenario inspired by a source
  but not itself claimed to be a source theorem;
- `upstream_registration`: registration of an external proof artifact rather
  than a local reimplementation;
- `interpretive_note`: explanatory prose that is not machine-checked.

When in doubt, use the weaker label. Theorem DNA should make interpretive
distance visible rather than hide it.

## Naming source theorems

Generic names such as `theorem_1_2` are acceptable inside a short paper slice,
but exported declarations and future claim IDs should include source context
when practical. For example:

```text
kjos_hanssen_theorem_1_2_collapse
claim:ctd:kjos-hanssen-theorem-1-2-collapse:v1
```

Aliases are preferable to disruptive renames once downstream metadata already
points at an existing declaration.
