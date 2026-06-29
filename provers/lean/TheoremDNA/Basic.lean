namespace TheoremDNA

structure ClaimDNA where
  sourceHash : String
  formulaHash : String
  contextHash : String
  proofHash : String
deriving Repr, BEq

end TheoremDNA
