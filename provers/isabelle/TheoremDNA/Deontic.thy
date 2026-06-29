theory Deontic
  imports Main
begin

locale deontic =
  fixes Obl :: "'w ⇒ bool"
  fixes Perm :: "'w ⇒ bool"
  assumes obligation_implies_permission:
    "∀w. Obl w ⟶ Perm w"

end
