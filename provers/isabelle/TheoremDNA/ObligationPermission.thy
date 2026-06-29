theory ObligationPermission
  imports Deontic
begin

context deontic
begin

theorem permission_from_obligation:
  assumes "Obl w"
  shows "Perm w"
  using assms obligation_implies_permission by blast

theorem obligation_entails_permission:
  "∀w. Obl w ⟶ Perm w"
  using obligation_implies_permission by blast

end

end
