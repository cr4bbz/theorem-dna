# Logic Profiles

A logic profile defines the object logic or meta-logic used by a claim.

Initial profiles:

```json
{
  "id": "classical-hol-v0",
  "name": "Classical Higher-Order Logic",
  "status": "draft"
}
```

```json
{
  "id": "minimal-deontic-v0",
  "name": "Minimal Deontic Logic Profile",
  "status": "draft",
  "primitive_predicates": ["Obl", "Perm"],
  "axioms": ["obligation_implies_permission"]
}
```
