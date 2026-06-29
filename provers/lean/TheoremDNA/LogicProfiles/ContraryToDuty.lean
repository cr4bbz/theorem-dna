namespace TheoremDNA.LogicProfiles.ContraryToDuty

def Proposition (World : Type) : Type :=
  World -> Prop

def Subset {World : Type} (left right : Proposition World) : Prop :=
  forall world, left world -> right world

def Intersects {World : Type} (left right : Proposition World) : Prop :=
  exists world, left world /\ right world

def Complement {World : Type} (value : Proposition World) : Proposition World :=
  fun world => Not (value world)

def Union {World : Type} (left right : Proposition World) : Proposition World :=
  fun world => left world \/ right world

def Difference {World : Type} (left right : Proposition World) : Proposition World :=
  fun world => left world /\ Not (right world)

def EquivalentInContext {World : Type}
    (context left right : Proposition World) : Prop :=
  forall world, context world -> (left world <-> right world)

def MutuallyGeneric {World : Type}
    (left right whole : Proposition World) : Prop :=
  Intersects left right /\
    Intersects left (Complement right) /\
    Intersects right (Complement left) /\
    Intersects whole (Complement (Union left right))

structure ObligationFunction (World : Type) where
  obligatory : Proposition World -> Proposition World -> Prop

def Condition5b {World : Type} (ob : ObligationFunction World) : Prop :=
  forall {context left right},
    EquivalentInContext context left right ->
    (ob.obligatory context left <-> ob.obligatory context right)

def Condition5d {World : Type} (ob : ObligationFunction World) : Prop :=
  forall {smallContext bigContext obligation},
    Subset smallContext bigContext ->
    ob.obligatory smallContext obligation ->
    ob.obligatory bigContext (Union (Difference bigContext smallContext) obligation)

def Condition5e {World : Type} (ob : ObligationFunction World) : Prop :=
  forall {restrictedContext broadContext obligation},
    Subset restrictedContext broadContext ->
    ob.obligatory broadContext obligation ->
    Intersects restrictedContext obligation ->
    ob.obligatory restrictedContext obligation

def CollapseWitness {World : Type} (ob : ObligationFunction World)
    (whole violated arbitrary : Proposition World) : Prop :=
  ob.obligatory whole violated ->
    ob.obligatory (Complement violated) arbitrary

structure CollapseDerivationData {World : Type}
    (whole violated arbitrary : Proposition World) where
  generic : MutuallyGeneric violated arbitrary whole
  step1Context : Proposition World
  step1Subset : Subset step1Context whole
  step1Intersects : Intersects step1Context violated
  step2Subset : Subset (Complement violated) whole
  step2Intersects : Intersects (Complement violated) (Union violated arbitrary)
  dResultEquivalent :
    EquivalentInContext whole
      (Union (Difference whole step1Context) violated)
      (Union violated arbitrary)
  finalEquivalent :
    EquivalentInContext (Complement violated) (Union violated arbitrary) arbitrary

theorem theorem_1_2_collapse_pattern {World : Type}
    (ob : ObligationFunction World)
    (condition5b : Condition5b ob)
    (condition5d : Condition5d ob)
    (condition5e : Condition5e ob)
    {whole violated arbitrary : Proposition World}
    (data : CollapseDerivationData whole violated arbitrary) :
    CollapseWitness ob whole violated arbitrary := by
  intro initialObligation
  have step1 : ob.obligatory data.step1Context violated :=
    condition5e data.step1Subset initialObligation data.step1Intersects
  have step2 :
      ob.obligatory whole
        (Union (Difference whole data.step1Context) violated) :=
    condition5d data.step1Subset step1
  have step3 : ob.obligatory whole (Union violated arbitrary) :=
    (condition5b data.dResultEquivalent).mp step2
  have step4 :
      ob.obligatory (Complement violated) (Union violated arbitrary) :=
    condition5e data.step2Subset step3 data.step2Intersects
  exact (condition5b data.finalEquivalent).mp step4

inductive RepairMode where
  | weak
  | strong
deriving Repr, BEq

structure IdealFunction (World : Type) where
  ideal : Proposition World -> Proposition World
  included :
    forall context, Subset (ideal context) context
  nonemptyOnPossible :
    forall context, Intersects context context -> Intersects (ideal context) (ideal context)

def WeakObligation {World : Type} (idealFunction : IdealFunction World) :
    ObligationFunction World where
  obligatory context obligation :=
    Subset (idealFunction.ideal context) obligation

def StrongObligation {World : Type} (idealFunction : IdealFunction World) :
    ObligationFunction World where
  obligatory context obligation :=
    EquivalentInContext context obligation (idealFunction.ideal context)

def RepairId {World : Type} (idealFunction : IdealFunction World) : Prop :=
  forall {context restriction},
    Subset restriction context ->
    Subset (idealFunction.ideal context) restriction ->
    Subset (idealFunction.ideal context) (idealFunction.ideal restriction)

def RepairIe {World : Type} (idealFunction : IdealFunction World) : Prop :=
  forall {context restriction},
    Subset restriction context ->
    Intersects (idealFunction.ideal context) restriction ->
    EquivalentInContext restriction
      (idealFunction.ideal restriction)
      (idealFunction.ideal context)

def RepairPackage {World : Type}
    (idealFunction : IdealFunction World) (mode : RepairMode) : Prop :=
  match mode with
  | RepairMode.weak => RepairId idealFunction
  | RepairMode.strong => RepairIe idealFunction

def UnsafeCarmoJonesPackage {World : Type} (ob : ObligationFunction World) : Prop :=
  Condition5b ob /\ Condition5d ob /\ Condition5e ob

def RepairedPackage {World : Type}
    (idealFunction : IdealFunction World) (mode : RepairMode) : Prop :=
  RepairPackage idealFunction mode

theorem repaired_package_keeps_conditions_separate {World : Type}
    (idealFunction : IdealFunction World)
    (mode : RepairMode)
    (repair : RepairedPackage idealFunction mode) :
    RepairPackage idealFunction mode := by
  exact repair

theorem weak_repair_is_not_the_unsafe_full_package {World : Type}
    (idealFunction : IdealFunction World)
    (repair : RepairedPackage idealFunction RepairMode.weak) :
    RepairId idealFunction :=
  repaired_package_keeps_conditions_separate idealFunction RepairMode.weak repair

theorem strong_repair_is_not_the_unsafe_full_package {World : Type}
    (idealFunction : IdealFunction World)
    (repair : RepairedPackage idealFunction RepairMode.strong) :
    RepairIe idealFunction :=
  repaired_package_keeps_conditions_separate idealFunction RepairMode.strong repair

end TheoremDNA.LogicProfiles.ContraryToDuty
