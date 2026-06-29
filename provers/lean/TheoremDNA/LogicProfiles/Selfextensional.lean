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

def BooleanConsequence : Consequence Bool where
  entails premises conclusion :=
    (∀ formula, premises formula -> formula = true) -> conclusion = true

def booleanConsequence_selfextensional :
    SelfextensionalConsequence Bool where
  entails := BooleanConsequence.entails
  respectsEquivalence := by
    intro left right equivalent premises
    constructor
    · intro derivesLeft allPremisesTrue
      exact equivalent.left (by
        intro formula inSingleton
        cases inSingleton
        exact derivesLeft allPremisesTrue)
    · intro derivesRight allPremisesTrue
      exact equivalent.right (by
        intro formula inSingleton
        cases inSingleton
        exact derivesRight allPremisesTrue)

structure PreorderFrame (Formula : Type) where
  le : Formula -> Formula -> Prop
  refl : ∀ formula, le formula formula
  trans : ∀ {left middle right}, le left middle -> le middle right -> le left right

def PreorderConsequence {Formula : Type} (frame : PreorderFrame Formula) :
    Consequence Formula where
  entails premises conclusion :=
    ∃ premise, premises premise ∧ frame.le premise conclusion

theorem preorderEntails_singleton {Formula : Type}
    (frame : PreorderFrame Formula)
    (left right : Formula)
    (derives : (PreorderConsequence frame).entails (singleton left) right) :
    frame.le left right := by
  rcases derives with ⟨premise, inSingleton, lePremiseRight⟩
  cases inSingleton
  exact lePremiseRight

def preorderConsequence_selfextensional {Formula : Type}
    (frame : PreorderFrame Formula) :
    SelfextensionalConsequence Formula where
  entails := (PreorderConsequence frame).entails
  respectsEquivalence := by
    intro left right equivalent premises
    have leftLeRight : frame.le left right :=
      preorderEntails_singleton frame left right equivalent.left
    have rightLeLeft : frame.le right left :=
      preorderEntails_singleton frame right left equivalent.right
    constructor
    · intro derivesLeft
      rcases derivesLeft with ⟨premise, inPremises, lePremiseLeft⟩
      exact ⟨premise, inPremises, frame.trans lePremiseLeft leftLeRight⟩
    · intro derivesRight
      rcases derivesRight with ⟨premise, inPremises, lePremiseRight⟩
      exact ⟨premise, inPremises, frame.trans lePremiseRight rightLeLeft⟩

inductive ThreeValuedFormula where
  | bottom
  | middle
  | top

def ThreeValuedFrame : PreorderFrame ThreeValuedFormula where
  le left right :=
    match left, right with
    | ThreeValuedFormula.bottom, _ => True
    | ThreeValuedFormula.middle, ThreeValuedFormula.middle => True
    | ThreeValuedFormula.middle, ThreeValuedFormula.top => True
    | ThreeValuedFormula.top, ThreeValuedFormula.top => True
    | _, _ => False
  refl := by
    intro formula
    cases formula <;> trivial
  trans := by
    intro left center right leftLeCenter centerLeRight
    cases left <;> cases center <;> cases right <;> trivial

def ThreeValuedConsequence : SelfextensionalConsequence ThreeValuedFormula :=
  preorderConsequence_selfextensional ThreeValuedFrame

end TheoremDNA.LogicProfiles.Selfextensional
