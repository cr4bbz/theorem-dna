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

namespace ContractorExample

inductive Situation where
  | renovation

inductive ActionStep where
  | safeFinish
  | unsafeFinish
  | noWork

inductive State where
  | doneSafely
  | doneWithAccident
  | notDone

def workDone : Predicate State :=
  fun state =>
    match state with
    | State.doneSafely => True
    | State.doneWithAccident => True
    | State.notDone => False

def accident : Predicate State :=
  fun state =>
    match state with
    | State.doneSafely => False
    | State.doneWithAccident => True
    | State.notDone => False

def completesWork : Predicate ActionStep :=
  fun action =>
    match action with
    | ActionStep.safeFinish => True
    | ActionStep.unsafeFinish => True
    | ActionStep.noWork => False

def unsafeWork : Predicate ActionStep :=
  fun action =>
    match action with
    | ActionStep.safeFinish => False
    | ActionStep.unsafeFinish => True
    | ActionStep.noWork => False

inductive RequiredState : Situation -> Predicate State -> Prop where
  | contract :
      RequiredState Situation.renovation workDone

inductive ForbiddenState : Situation -> Predicate State -> Prop where
  | noAccident :
      ForbiddenState Situation.renovation accident

inductive Realizes : Predicate ActionStep -> Predicate State -> Prop where
  | completion :
      Realizes completesWork workDone

inductive Avoids : Predicate ActionStep -> Predicate State -> Prop where
  | unsafeAvoidsNoAccident :
      Avoids unsafeWork (Complement accident)

mutual
  inductive RequiredAction : Situation -> Predicate ActionStep -> Prop where
    | fromRequiredState {situation action state} :
        RequiredState situation state ->
        Realizes action state ->
        RequiredAction situation action
    | agglomeration {situation left right} :
        RequiredAction situation left ->
        RequiredAction situation right ->
        RequiredAction situation (Intersect left right)
    | trimming {situation obligation prohibition} :
        RequiredAction situation obligation ->
        ForbiddenAction situation prohibition ->
        RequiredAction situation (Difference obligation prohibition)

  inductive ForbiddenAction : Situation -> Predicate ActionStep -> Prop where
    | safetyRule :
        ForbiddenAction Situation.renovation unsafeWork
    | fromForbiddenState {situation action state} :
        ForbiddenState situation state ->
        Avoids action (Complement state) ->
        ForbiddenAction situation action
    | downward {situation broad specific} :
        ForbiddenAction situation broad ->
        Subset specific broad ->
        ForbiddenAction situation specific
    | agglomeration {situation left right} :
        ForbiddenAction situation left ->
        ForbiddenAction situation right ->
        ForbiddenAction situation (Union left right)
    | economy {situation obligation} :
        RequiredAction situation obligation ->
        ForbiddenAction situation (Complement obligation)
end

def Frame : DeonticFrame Situation ActionStep State where
  requiredAction := RequiredAction
  forbiddenAction := ForbiddenAction
  requiredState := RequiredState
  forbiddenState := ForbiddenState

def Bridges : BridgePrinciples Situation ActionStep State Frame where
  realizes := Realizes
  avoids := Avoids
  requiredStateToAction := RequiredAction.fromRequiredState
  forbiddenStateToAction := ForbiddenAction.fromForbiddenState

def ActionPrinciples : ActionClosurePrinciples Situation ActionStep State Frame where
  requiredAgglomeration := RequiredAction.agglomeration
  forbiddenDownward := ForbiddenAction.downward
  forbiddenAgglomeration := ForbiddenAction.agglomeration
  trimming := RequiredAction.trimming
  economy := ForbiddenAction.economy

theorem contract_requires_completion_action :
    Frame.requiredAction Situation.renovation completesWork :=
  required_action_from_required_state Frame Bridges
    RequiredState.contract Realizes.completion

theorem safety_forbids_unsafe_work :
    Frame.forbiddenAction Situation.renovation unsafeWork :=
  ForbiddenAction.safetyRule

theorem contract_and_safety_require_trimmed_safe_completion :
    Frame.requiredAction Situation.renovation
      (Difference completesWork unsafeWork) :=
  trimmed_obligation_avoids_forbidden_part Frame ActionPrinciples
    contract_requires_completion_action safety_forbids_unsafe_work

theorem no_accident_bridge_forbids_unsafe_work :
    Frame.forbiddenAction Situation.renovation unsafeWork :=
  forbidden_action_from_forbidden_state Frame Bridges
    ForbiddenState.noAccident Avoids.unsafeAvoidsNoAccident

theorem contractor_most_general_prohibition_candidate :
    Frame.forbiddenAction Situation.renovation
      (Union unsafeWork (Complement completesWork)) :=
  ActionPrinciples.forbiddenAgglomeration
    safety_forbids_unsafe_work
    (ActionPrinciples.economy contract_requires_completion_action)

end ContractorExample

end TheoremDNA.LogicProfiles.ActionState
