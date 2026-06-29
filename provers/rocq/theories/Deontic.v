From Stdlib Require Import Init.Logic.

Module Deontic.

Parameter World : Type.
Parameter Obl : World -> Prop.
Parameter Perm : World -> Prop.

Axiom obligation_implies_permission :
  forall w : World, Obl w -> Perm w.

Theorem permission_from_obligation :
  forall w : World, Obl w -> Perm w.
Proof.
  intros w h.
  apply obligation_implies_permission.
  exact h.
Qed.

Theorem obligation_entails_permission :
  forall w : World, Obl w -> Perm w.
Proof.
  exact obligation_implies_permission.
Qed.

End Deontic.
