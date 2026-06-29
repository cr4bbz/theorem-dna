namespace TheoremDNA.LogicProfiles.Selfextensional

def FormulaSet (Formula : Type) : Type :=
  Formula -> Prop

def singleton {Formula : Type} (formula : Formula) : FormulaSet Formula :=
  fun candidate => candidate = formula

structure Consequence (Formula : Type) where
  entails : FormulaSet Formula -> Formula -> Prop

def Closure {Formula : Type} (logic : Consequence Formula) (premises : FormulaSet Formula) :
    FormulaSet Formula :=
  fun formula => logic.entails premises formula

def Equivalent {Formula : Type} (logic : Consequence Formula)
    (left right : Formula) : Prop :=
  logic.entails (singleton left) right ∧ logic.entails (singleton right) left

structure SelfextensionalConsequence (Formula : Type) extends Consequence Formula where
  respectsEquivalence :
    ∀ {left right : Formula},
      Equivalent toConsequence left right ->
      ∀ {premises : FormulaSet Formula},
        (entails premises left ↔ entails premises right)

structure NormativeSystem (Formula : Type) where
  norms : Formula -> Formula -> Prop

def DirectlyTriggered {Formula : Type} (system : NormativeSystem Formula)
    (inputs : FormulaSet Formula) (output : Formula) : Prop :=
  ∃ input, inputs input ∧ system.norms input output

def simpleOutput {Formula : Type} (logic : Consequence Formula)
    (system : NormativeSystem Formula) (inputs : FormulaSet Formula) : FormulaSet Formula :=
  fun output =>
    ∃ directOutput,
      DirectlyTriggered system inputs directOutput ∧
      logic.entails (singleton directOutput) output

structure Negation (Formula : Type) where
  neg : Formula -> Formula

def negativePermission {Formula : Type} (negation : Negation Formula)
    (obligatory : Formula -> Prop) (formula : Formula) : Prop :=
  ¬ obligatory (negation.neg formula)

def dualNegativePermission {Formula : Type} (negation : Negation Formula)
    (forbidden : Formula -> Prop) (formula : Formula) : Prop :=
  ¬ forbidden formula ∧ ¬ forbidden (negation.neg formula)

theorem simpleOutput_contains_direct_outputs {Formula : Type}
    (logic : Consequence Formula)
    (system : NormativeSystem Formula)
    (inputs : FormulaSet Formula)
    (reflexive : ∀ formula, logic.entails (singleton formula) formula)
    (output : Formula)
    (triggered : DirectlyTriggered system inputs output) :
    simpleOutput logic system inputs output := by
  exact ⟨output, triggered, reflexive output⟩

theorem negativePermission_of_no_contrary_obligation {Formula : Type}
    (negation : Negation Formula)
    (obligatory : Formula -> Prop)
    (formula : Formula)
    (notContraryObligatory : ¬ obligatory (negation.neg formula)) :
    negativePermission negation obligatory formula := by
  exact notContraryObligatory

theorem dualNegativePermission_left {Formula : Type}
    (negation : Negation Formula)
    (forbidden : Formula -> Prop)
    (formula : Formula)
    (permission : dualNegativePermission negation forbidden formula) :
    ¬ forbidden formula := by
  exact permission.left

end TheoremDNA.LogicProfiles.Selfextensional
