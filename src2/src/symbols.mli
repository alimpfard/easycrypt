(* -------------------------------------------------------------------- *)
type symbol  = (* private *) string
type qsymbol = (* private *) symbol list * symbol

(* -------------------------------------------------------------------- *)
module SymMap : Map.S with type key = symbol
