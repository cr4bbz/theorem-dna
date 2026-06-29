namespace TheoremDNA.Deontic

variable {World : Type}
variable (Obl Perm : World → Prop)

axiom obligation_implies_permission :
  ∀ w : World, Obl w → Perm w

theorem permission_from_obligation
  (w : World)
  (h : Obl w) :
  Perm w :=
  obligation_implies_permission Obl Perm w h

theorem obligation_entails_permission :
  ∀ w : World, Obl w → Perm w :=
  obligation_implies_permission Obl Perm

end TheoremDNA.Deontic
