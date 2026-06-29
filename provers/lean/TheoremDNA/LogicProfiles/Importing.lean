namespace TheoremDNA.LogicProfiles.Importing

structure Semantics (Formula Model : Type) where
  satisfies : Model -> Formula -> Prop

def Valid {Formula Model : Type} (semantics : Semantics Formula Model)
    (formula : Formula) : Prop :=
  ∀ model, semantics.satisfies model formula

structure DeductiveSystem (Formula : Type) where
  derives : Formula -> Prop

def Sound {Formula Model : Type} (system : DeductiveSystem Formula)
    (semantics : Semantics Formula Model) : Prop :=
  ∀ {formula}, system.derives formula -> Valid semantics formula

structure Translation (SourceFormula TargetFormula : Type) where
  translate : SourceFormula -> TargetFormula

structure SemanticImport
    (SourceFormula SourceModel TargetFormula TargetModel : Type)
    (sourceSemantics : Semantics SourceFormula SourceModel)
    (targetSemantics : Semantics TargetFormula TargetModel)
    (translation : Translation SourceFormula TargetFormula) where
  reduct : TargetModel -> SourceModel
  preservesTruth :
    ∀ {targetModel sourceFormula},
      sourceSemantics.satisfies (reduct targetModel) sourceFormula ->
      targetSemantics.satisfies targetModel
        (translation.translate sourceFormula)

def ImportedSystem {SourceFormula TargetFormula : Type}
    (source : DeductiveSystem SourceFormula)
    (translation : Translation SourceFormula TargetFormula) :
    DeductiveSystem TargetFormula where
  derives targetFormula :=
    ∃ sourceFormula,
      source.derives sourceFormula ∧
      targetFormula = translation.translate sourceFormula

theorem imported_theorem_sound
    {SourceFormula SourceModel TargetFormula TargetModel : Type}
    (sourceSystem : DeductiveSystem SourceFormula)
    (sourceSemantics : Semantics SourceFormula SourceModel)
    (targetSemantics : Semantics TargetFormula TargetModel)
    (translation : Translation SourceFormula TargetFormula)
    (semanticImport :
      SemanticImport
        SourceFormula SourceModel TargetFormula TargetModel
        sourceSemantics targetSemantics translation)
    (sourceSound : Sound sourceSystem sourceSemantics) :
    Sound (ImportedSystem sourceSystem translation) targetSemantics := by
  intro targetFormula importedDerivation targetModel
  rcases importedDerivation with ⟨sourceFormula, sourceDerivation, translated⟩
  cases translated
  exact semanticImport.preservesTruth
    (sourceSound sourceDerivation (semanticImport.reduct targetModel))

inductive MinimalFormula where
  | truth

inductive MinimalModel where
  | point

def MinimalSemantics : Semantics MinimalFormula MinimalModel where
  satisfies _ formula :=
    match formula with
    | MinimalFormula.truth => True

def MinimalSystem : DeductiveSystem MinimalFormula where
  derives formula :=
    match formula with
    | MinimalFormula.truth => True

theorem minimalSystem_sound : Sound MinimalSystem MinimalSemantics := by
  intro formula derivation model
  cases formula
  trivial

def IdentityTranslation : Translation MinimalFormula MinimalFormula where
  translate formula := formula

def IdentityImport :
    SemanticImport
      MinimalFormula MinimalModel MinimalFormula MinimalModel
      MinimalSemantics MinimalSemantics IdentityTranslation where
  reduct model := model
  preservesTruth := by
    intro targetModel sourceFormula truth
    exact truth

theorem minimal_import_sound :
    Sound (ImportedSystem MinimalSystem IdentityTranslation) MinimalSemantics :=
  imported_theorem_sound
    MinimalSystem
    MinimalSemantics
    MinimalSemantics
    IdentityTranslation
    IdentityImport
    minimalSystem_sound

end TheoremDNA.LogicProfiles.Importing
