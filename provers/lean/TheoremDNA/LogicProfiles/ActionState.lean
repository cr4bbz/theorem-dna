namespace TheoremDNA.LogicProfiles.ActionState

def Predicate (Entity : Type) : Type :=
  Entity -> Prop

def Subset {Entity : Type} (left right : Predicate Entity) : Prop :=
  ∀ entity, left entity -> right entity

def Intersect {Entity : Type} (left right : Predicate Entity) : Predicate Entity :=
  fun entity => left entity ∧ right entity

def Union {Entity : Type} (left right : Predicate Entity) : Predicate Entity :=
  fun entity => left entity ∨ right entity

def Complement {Entity : Type} (value : Predicate Entity) : Predicate Entity :=
  fun entity => ¬ value entity

def Difference {Entity : Type} (left right : Predicate Entity) : Predicate Entity :=
  fun entity => left entity ∧ ¬ right entity

structure DeonticFrame (Situation ActionStep State : Type) where
  requiredAction : Situation -> Predicate ActionStep -> Prop
  forbiddenAction : Situation -> Predicate ActionStep -> Prop
  requiredState : Situation -> Predicate State -> Prop
  forbiddenState : Situation -> Predicate State -> Prop

structure BridgePrinciples (Situation ActionStep State : Type)
    (frame : DeonticFrame Situation ActionStep State) where
  realizes : Predicate ActionStep -> Predicate State -> Prop
  avoids : Predicate ActionStep -> Predicate State -> Prop
  requiredStateToAction :
    ∀ {situation action state},
      frame.requiredState situation state ->
      realizes action state ->
      frame.requiredAction situation action
  forbiddenStateToAction :
    ∀ {situation action state},
      frame.forbiddenState situation state ->
      avoids action (Complement state) ->
      frame.forbiddenAction situation action

structure ActionClosurePrinciples (Situation ActionStep State : Type)
    (frame : DeonticFrame Situation ActionStep State) where
  requiredAgglomeration :
    ∀ {situation left right},
      frame.requiredAction situation left ->
      frame.requiredAction situation right ->
      frame.requiredAction situation (Intersect left right)
  forbiddenDownward :
    ∀ {situation broad specific},
      frame.forbiddenAction situation broad ->
      Subset specific broad ->
      frame.forbiddenAction situation specific
  forbiddenAgglomeration :
    ∀ {situation left right},
      frame.forbiddenAction situation left ->
      frame.forbiddenAction situation right ->
      frame.forbiddenAction situation (Union left right)
  trimming :
    ∀ {situation obligation prohibition},
      frame.requiredAction situation obligation ->
      frame.forbiddenAction situation prohibition ->
      frame.requiredAction situation (Difference obligation prohibition)
  economy :
    ∀ {situation obligation},
      frame.requiredAction situation obligation ->
      frame.forbiddenAction situation (Complement obligation)

def MostSpecificObligation {Situation ActionStep State : Type}
    (frame : DeonticFrame Situation ActionStep State)
    (situation : Situation) (candidate : Predicate ActionStep) : Prop :=
  frame.requiredAction situation candidate ∧
    ∀ other, frame.requiredAction situation other -> Subset candidate other

def MostGeneralProhibition {Situation ActionStep State : Type}
    (frame : DeonticFrame Situation ActionStep State)
    (situation : Situation) (candidate : Predicate ActionStep) : Prop :=
  frame.forbiddenAction situation candidate ∧
    ∀ other, frame.forbiddenAction situation other -> Subset other candidate

theorem required_action_from_required_state {Situation ActionStep State : Type}
    (frame : DeonticFrame Situation ActionStep State)
    (bridges : BridgePrinciples Situation ActionStep State frame)
    {situation : Situation}
    {action : Predicate ActionStep}
    {state : Predicate State}
    (stateObligation : frame.requiredState situation state)
    (realization : bridges.realizes action state) :
    frame.requiredAction situation action := by
  exact bridges.requiredStateToAction stateObligation realization

theorem forbidden_action_from_forbidden_state {Situation ActionStep State : Type}
    (frame : DeonticFrame Situation ActionStep State)
    (bridges : BridgePrinciples Situation ActionStep State frame)
    {situation : Situation}
    {action : Predicate ActionStep}
    {state : Predicate State}
    (stateProhibition : frame.forbiddenState situation state)
    (avoidance : bridges.avoids action (Complement state)) :
    frame.forbiddenAction situation action := by
  exact bridges.forbiddenStateToAction stateProhibition avoidance

theorem binary_most_specific_obligation_candidate {Situation ActionStep State : Type}
    (frame : DeonticFrame Situation ActionStep State)
    (principles : ActionClosurePrinciples Situation ActionStep State frame)
    {situation : Situation}
    {first second : Predicate ActionStep}
    (firstObligation : frame.requiredAction situation first)
    (secondObligation : frame.requiredAction situation second) :
    frame.requiredAction situation (Intersect first second) ∧
      Subset (Intersect first second) first ∧
      Subset (Intersect first second) second := by
  constructor
  · exact principles.requiredAgglomeration firstObligation secondObligation
  · constructor
    · intro step candidateH
      exact candidateH.left
    · intro step candidateH
      exact candidateH.right

theorem binary_most_general_prohibition_candidate {Situation ActionStep State : Type}
    (frame : DeonticFrame Situation ActionStep State)
    (principles : ActionClosurePrinciples Situation ActionStep State frame)
    {situation : Situation}
    {first second : Predicate ActionStep}
    (firstProhibition : frame.forbiddenAction situation first)
    (secondProhibition : frame.forbiddenAction situation second) :
    frame.forbiddenAction situation (Union first second) ∧
      Subset first (Union first second) ∧
      Subset second (Union first second) := by
  constructor
  · exact principles.forbiddenAgglomeration firstProhibition secondProhibition
  · constructor
    · intro step firstH
      exact Or.inl firstH
    · intro step secondH
      exact Or.inr secondH

theorem trimmed_obligation_avoids_forbidden_part {Situation ActionStep State : Type}
    (frame : DeonticFrame Situation ActionStep State)
    (principles : ActionClosurePrinciples Situation ActionStep State frame)
    {situation : Situation}
    {obligation prohibition : Predicate ActionStep}
    (obligationH : frame.requiredAction situation obligation)
    (prohibitionH : frame.forbiddenAction situation prohibition) :
    frame.requiredAction situation (Difference obligation prohibition) :=
  principles.trimming obligationH prohibitionH

end TheoremDNA.LogicProfiles.ActionState
