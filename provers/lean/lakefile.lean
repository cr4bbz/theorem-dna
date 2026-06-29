import Lake
open Lake DSL

package «TheoremDNA» where
  version := v!"0.1.0"

@[default_target]
lean_lib TheoremDNA where
  roots := #[`TheoremDNA]
