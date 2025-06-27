(* model/types.mli *)
(* Interface file that exports all types and constructors *)

type comparison = {
  rel : string;
  lhs : string;
  rhs : float;
}

type range_check = {
  var : string;
  min : float;
  max : float;
}

type clause =
  | Requires of comparison
  | Within of range_check

type symbolic_contract = {
  contract_id : string;
  clause : clause;
  critical : bool;
}

type pde_model = {
  id : string;
  domain : string;
  operator : string;
  boundary_conditions : (string * string) list;
  parameters : (string * float) list;
  contracts : symbolic_contract list;
}
