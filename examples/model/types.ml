(* model/types.ml *)

(* Core types for PDE model and symbolic contracts *)
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


(* parser/contract_parser.ml *)

open Yojson.Basic.Util
open Model.Types

let parse_clause json =
  if member "requires" json != `Null then
    let req = json |> member "requires" in
    let cmp = {
      rel = req |> member "rel" |> to_string;
      lhs = req |> member "lhs" |> to_string;
      rhs = req |> member "rhs" |> to_float;
    } in
    Requires cmp
  else if member "within" json != `Null then
    let w = json |> member "within" in
    let r = {
      var = w |> member "var" |> to_string;
      min = w |> member "min" |> to_float;
      max = w |> member "max" |> to_float;
    } in
    Within r
  else
    failwith "Unknown clause format"

let parse_contract json = {
  contract_id = json |> member "contract_id" |> to_string;
  clause = json |> member "clause" |> parse_clause;
  critical = json |> member "critical" |> to_bool;
}

let parse_pde_model json = {
  id = json |> member "id" |> to_string;
  domain = json |> member "domain" |> to_string;
  operator = json |> member "operator" |> to_string;
  boundary_conditions = json |> member "boundary_conditions"
    |> to_assoc |> List.map (fun (k,v) -> (k, to_string v));
  parameters = json |> member "parameters"
    |> to_assoc |> List.map (fun (k,v) -> (k, to_float v));
  contracts = json |> member "contracts"
    |> to_list |> List.map parse_contract;
}

let parse_models json =
  json |> to_list |> List.map parse_pde_model
