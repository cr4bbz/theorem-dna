theory Deontic
  imports Main
begin

locale deontic =
  fixes Obl :: "'w \<Rightarrow> bool"
  fixes Perm :: "'w \<Rightarrow> bool"
  assumes obligation_implies_permission:
    "\<forall>w. Obl w \<longrightarrow> Perm w"

end
