namespace TheoremDNA.LogicProfiles.ADeL0

inductive ActionTerm where
  | zero
  | one
  | complement : ActionTerm -> ActionTerm
  | choice : ActionTerm -> ActionTerm -> ActionTerm
  | conjunction : ActionTerm -> ActionTerm -> ActionTerm
deriving Repr, BEq

inductive Formula where
  | atom : String -> Formula
  | falsum
  | neg : Formula -> Formula
  | and : Formula -> Formula -> Formula
  | imp : Formula -> Formula -> Formula
  | universal : Formula -> Formula
  | agentSettled : Formula -> Formula
  | next : Formula -> Formula
  | done : ActionTerm -> Formula
  | obligatory : ActionTerm -> Formula
deriving Repr, BEq

structure ADeL0Model (World : Type) where
  globallyAccessible : World -> World -> Prop
  agentAlternative : World -> World -> Prop
  immediateFuture : World -> World -> Prop
  doneAction : World -> ActionTerm -> Prop
  obligated : World -> ActionTerm -> Prop

structure ADeL0FrameConditions {World : Type} (model : ADeL0Model World) where
  doneOne :
    ∀ world, model.doneAction world ActionTerm.one
  doneComplement :
    ∀ world action,
      model.doneAction world (ActionTerm.complement action) ↔
        ¬ model.doneAction world action
  doneChoice :
    ∀ world left right,
      model.doneAction world (ActionTerm.choice left right) ↔
        model.doneAction world left ∨ model.doneAction world right
  doneConjunction :
    ∀ world left right,
      model.doneAction world (ActionTerm.conjunction left right) ↔
        model.doneAction world left ∧ model.doneAction world right
  obligationIdempotent :
    ∀ world action,
      model.obligated world (ActionTerm.conjunction action action) ↔
        model.obligated world action
  obligationCommutative :
    ∀ world left right,
      model.obligated world (ActionTerm.conjunction left right) ↔
        model.obligated world (ActionTerm.conjunction right left)
  obligationAssociative :
    ∀ world left middle right,
      model.obligated world
        (ActionTerm.conjunction left (ActionTerm.conjunction middle right)) ↔
        model.obligated world
          (ActionTerm.conjunction (ActionTerm.conjunction left middle) right)
  impossibleNotObligatory :
    ∀ world, ¬ model.obligated world ActionTerm.zero
  obligationAgglomeration :
    ∀ world left right,
      model.obligated world left ->
      model.obligated world right ->
      model.obligated world (ActionTerm.conjunction left right)
  universalImpliesAgentSettled :
    ∀ {world target},
      model.globallyAccessible world target ->
      model.agentAlternative world target
  universalImpliesNext :
    ∀ {world target},
      model.globallyAccessible world target ->
      model.immediateFuture world target
  nextImpliesSettledNext :
    ∀ {world target future},
      model.immediateFuture world target ->
      model.agentAlternative target future ->
      model.immediateFuture world future

theorem d1_done_one {World : Type}
    (model : ADeL0Model World)
    (conditions : ADeL0FrameConditions model)
    (world : World) :
    model.doneAction world ActionTerm.one :=
  conditions.doneOne world

theorem d3_done_choice {World : Type}
    (model : ADeL0Model World)
    (conditions : ADeL0FrameConditions model)
    (world : World)
    (left right : ActionTerm) :
    model.doneAction world (ActionTerm.choice left right) ↔
      model.doneAction world left ∨ model.doneAction world right :=
  conditions.doneChoice world left right

theorem d4_done_conjunction {World : Type}
    (model : ADeL0Model World)
    (conditions : ADeL0FrameConditions model)
    (world : World)
    (left right : ActionTerm) :
    model.doneAction world (ActionTerm.conjunction left right) ↔
      model.doneAction world left ∧ model.doneAction world right :=
  conditions.doneConjunction world left right

theorem o4_impossible_not_obligatory {World : Type}
    (model : ADeL0Model World)
    (conditions : ADeL0FrameConditions model)
    (world : World) :
    ¬ model.obligated world ActionTerm.zero :=
  conditions.impossibleNotObligatory world

theorem o5_obligation_agglomeration {World : Type}
    (model : ADeL0Model World)
    (conditions : ADeL0FrameConditions model)
    (world : World)
    (left right : ActionTerm)
    (leftObligation : model.obligated world left)
    (rightObligation : model.obligated world right) :
    model.obligated world (ActionTerm.conjunction left right) :=
  conditions.obligationAgglomeration
    world left right leftObligation rightObligation

theorem b1_global_accessibility_bridges_to_agent_alternative {World : Type}
    (model : ADeL0Model World)
    (conditions : ADeL0FrameConditions model)
    {world target : World}
    (global : model.globallyAccessible world target) :
    model.agentAlternative world target :=
  conditions.universalImpliesAgentSettled global

theorem b2_global_accessibility_bridges_to_next {World : Type}
    (model : ADeL0Model World)
    (conditions : ADeL0FrameConditions model)
    {world target : World}
    (global : model.globallyAccessible world target) :
    model.immediateFuture world target :=
  conditions.universalImpliesNext global

theorem b3_next_bridges_to_settled_next {World : Type}
    (model : ADeL0Model World)
    (conditions : ADeL0FrameConditions model)
    {world target future : World}
    (next : model.immediateFuture world target)
    (settled : model.agentAlternative target future) :
    model.immediateFuture world future :=
  conditions.nextImpliesSettledNext next settled

inductive TinyWorld where
  | start
  | finish

def evalDone : ActionTerm -> Prop
  | ActionTerm.zero => False
  | ActionTerm.one => True
  | ActionTerm.complement action => ¬ evalDone action
  | ActionTerm.choice left right => evalDone left ∨ evalDone right
  | ActionTerm.conjunction left right => evalDone left ∧ evalDone right

def evalObligated : ActionTerm -> Prop
  | ActionTerm.zero => False
  | ActionTerm.one => True
  | ActionTerm.complement action => evalObligated action
  | ActionTerm.choice left right => evalObligated left ∨ evalObligated right
  | ActionTerm.conjunction left right => evalObligated left ∧ evalObligated right

def TinyModel : ADeL0Model TinyWorld where
  globallyAccessible _ _ := True
  agentAlternative _ _ := True
  immediateFuture _ _ := True
  doneAction _ action := evalDone action
  obligated _ action := evalObligated action

def TinyConditions : ADeL0FrameConditions TinyModel where
  doneOne := by
    intro world
    trivial
  doneComplement := by
    intro world action
    simp [TinyModel, evalDone]
  doneChoice := by
    intro world left right
    simp [TinyModel, evalDone]
  doneConjunction := by
    intro world left right
    simp [TinyModel, evalDone]
  obligationIdempotent := by
    intro world action
    induction action <;> simp [TinyModel, evalObligated, *]
  obligationCommutative := by
    intro world left right
    simp [TinyModel, evalObligated, And.comm]
  obligationAssociative := by
    intro world left middle right
    simp [TinyModel, evalObligated]
    constructor
    · intro h
      exact ⟨⟨h.left, h.right.left⟩, h.right.right⟩
    · intro h
      exact ⟨h.left.left, h.left.right, h.right⟩
  impossibleNotObligatory := by
    intro world
    simp [TinyModel, evalObligated]
  obligationAgglomeration := by
    intro world left right leftObligation rightObligation
    exact And.intro leftObligation rightObligation
  universalImpliesAgentSettled := by
    intro world target global
    trivial
  universalImpliesNext := by
    intro world target global
    trivial
  nextImpliesSettledNext := by
    intro world target future next settled
    trivial

theorem tiny_obligation_agglomerates
    (left right : ActionTerm)
    (leftObligation : TinyModel.obligated TinyWorld.start left)
    (rightObligation : TinyModel.obligated TinyWorld.start right) :
    TinyModel.obligated TinyWorld.start
      (ActionTerm.conjunction left right) :=
  o5_obligation_agglomeration
    TinyModel TinyConditions TinyWorld.start left right
    leftObligation rightObligation

end TheoremDNA.LogicProfiles.ADeL0
