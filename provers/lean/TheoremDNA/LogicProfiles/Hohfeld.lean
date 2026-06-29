namespace TheoremDNA.LogicProfiles.Hohfeld

/-!
This profile records the relational core of Hohfeldian legal positions.

Markovich's formalization emphasizes that Hohfeldian rights and duties are not
one-place deontic labels: they are directed positions between agents, with a
content act.  This file keeps that core independent from any particular modal
semantics so later profiles can import it as a typed relation layer.
-/

structure HohfeldFrame (Agent Act : Type) where
  claimRight : Agent -> Agent -> Act -> Prop
  duty : Agent -> Agent -> Act -> Prop
  privilege : Agent -> Agent -> Act -> Prop
  noClaim : Agent -> Agent -> Act -> Prop
  power : Agent -> Agent -> Act -> Prop
  liability : Agent -> Agent -> Act -> Prop
  immunity : Agent -> Agent -> Act -> Prop
  disability : Agent -> Agent -> Act -> Prop

structure CorrelativeLaws {Agent Act : Type}
    (frame : HohfeldFrame Agent Act) : Prop where
  claimDuty :
    forall {holder bearer act},
      frame.claimRight holder bearer act <->
        frame.duty bearer holder act
  privilegeNoClaim :
    forall {holder counterparty act},
      frame.privilege holder counterparty act <->
        frame.noClaim counterparty holder act
  powerLiability :
    forall {holder target act},
      frame.power holder target act <->
        frame.liability target holder act
  immunityDisability :
    forall {holder target act},
      frame.immunity holder target act <->
        frame.disability target holder act

structure OppositionLaws {Agent Act : Type}
    (frame : HohfeldFrame Agent Act) : Prop where
  claimRightNoClaim :
    forall {holder counterparty act},
      Not (frame.claimRight holder counterparty act /\
        frame.noClaim holder counterparty act)
  privilegeDuty :
    forall {holder counterparty act},
      Not (frame.privilege holder counterparty act /\
        frame.duty holder counterparty act)
  powerDisability :
    forall {holder target act},
      Not (frame.power holder target act /\
        frame.disability holder target act)
  immunityLiability :
    forall {holder target act},
      Not (frame.immunity holder target act /\
        frame.liability holder target act)

theorem claim_right_correlative_duty {Agent Act : Type}
    {frame : HohfeldFrame Agent Act}
    (laws : CorrelativeLaws frame)
    {holder bearer : Agent}
    {act : Act} :
    frame.claimRight holder bearer act <->
      frame.duty bearer holder act :=
  laws.claimDuty

theorem privilege_correlative_no_claim {Agent Act : Type}
    {frame : HohfeldFrame Agent Act}
    (laws : CorrelativeLaws frame)
    {holder counterparty : Agent}
    {act : Act} :
    frame.privilege holder counterparty act <->
      frame.noClaim counterparty holder act :=
  laws.privilegeNoClaim

theorem power_correlative_liability {Agent Act : Type}
    {frame : HohfeldFrame Agent Act}
    (laws : CorrelativeLaws frame)
    {holder target : Agent}
    {act : Act} :
    frame.power holder target act <->
      frame.liability target holder act :=
  laws.powerLiability

theorem immunity_correlative_disability {Agent Act : Type}
    {frame : HohfeldFrame Agent Act}
    (laws : CorrelativeLaws frame)
    {holder target : Agent}
    {act : Act} :
    frame.immunity holder target act <->
      frame.disability target holder act :=
  laws.immunityDisability

theorem claim_right_excludes_no_claim {Agent Act : Type}
    {frame : HohfeldFrame Agent Act}
    (laws : OppositionLaws frame)
    {holder counterparty : Agent}
    {act : Act} :
    Not (frame.claimRight holder counterparty act /\
      frame.noClaim holder counterparty act) :=
  laws.claimRightNoClaim

theorem privilege_excludes_duty {Agent Act : Type}
    {frame : HohfeldFrame Agent Act}
    (laws : OppositionLaws frame)
    {holder counterparty : Agent}
    {act : Act} :
    Not (frame.privilege holder counterparty act /\
      frame.duty holder counterparty act) :=
  laws.privilegeDuty

namespace TinyExample

inductive Agent where
  | alice
  | bob
deriving DecidableEq, Repr

inductive Act where
  | stayAway
  | enterLand
  | sellParcel
  | alterTaxStatus
deriving DecidableEq, Repr

def ClaimPair (holder bearer : Agent) (act : Act) : Prop :=
  holder = Agent.alice /\ bearer = Agent.bob /\ act = Act.stayAway

def PrivilegePair (holder counterparty : Agent) (act : Act) : Prop :=
  holder = Agent.bob /\ counterparty = Agent.alice /\ act = Act.enterLand

def PowerPair (holder target : Agent) (act : Act) : Prop :=
  holder = Agent.alice /\ target = Agent.bob /\ act = Act.sellParcel

def ImmunityPair (holder target : Agent) (act : Act) : Prop :=
  holder = Agent.alice /\ target = Agent.bob /\ act = Act.alterTaxStatus

def frame : HohfeldFrame Agent Act where
  claimRight holder bearer act := ClaimPair holder bearer act
  duty bearer holder act := ClaimPair holder bearer act
  privilege holder counterparty act := PrivilegePair holder counterparty act
  noClaim holder counterparty act := PrivilegePair counterparty holder act
  power holder target act := PowerPair holder target act
  liability target holder act := PowerPair holder target act
  immunity holder target act := ImmunityPair holder target act
  disability target holder act := ImmunityPair holder target act

def correlatives : CorrelativeLaws frame where
  claimDuty := Iff.rfl
  privilegeNoClaim := Iff.rfl
  powerLiability := Iff.rfl
  immunityDisability := Iff.rfl

theorem alice_claims_bobs_duty_to_stay_away :
    frame.claimRight Agent.alice Agent.bob Act.stayAway :=
  And.intro rfl (And.intro rfl rfl)

theorem bobs_duty_correlates_with_alices_claim :
    frame.duty Agent.bob Agent.alice Act.stayAway :=
  (claim_right_correlative_duty correlatives).mp
    alice_claims_bobs_duty_to_stay_away

theorem alice_power_correlates_with_bobs_liability :
    frame.power Agent.alice Agent.bob Act.sellParcel <->
      frame.liability Agent.bob Agent.alice Act.sellParcel :=
  power_correlative_liability correlatives

end TinyExample

end TheoremDNA.LogicProfiles.Hohfeld
