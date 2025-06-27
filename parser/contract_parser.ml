(* parser/contract_parser.ml *)

open Yojson.Basic.Util
open Model.Types
open Json_utils

(* Parse a clause from JSON *)
let parse_clause json =
  if json |> member "requires" <> `Null then
    let req = json |> member "requires" in
    let c = {
      rel = req |> member "rel" |> to_string;
      lhs = req |> member "lhs" |> to_string;
      rhs = req |> member "rhs" |> to_safe_float
    } in
    Requires c
  else if json |> member "within" <> `Null then
    let range = json |> member "within" in
    let r = {
      var = range |> member "var" |> to_string;
      min = range |> member "min" |> to_safe_float;
      max = range |> member "max" |> to_safe_float
    } in
    Within r
  else
    failwith "Unknown clause type"

(* Parse a symbolic contract from JSON *)
let parse_contract json = {
  contract_id = json |> member "contract_id" |> to_string;
  clause = json |> member "clause" |> parse_clause;
  critical = json |> member "critical" |> to_bool
}

(* Parse a PDE model from JSON *)
let parse_model json =
  let boundary_conditions =
    json |> member "boundary_conditions"
         |> to_assoc
         |> List.map (fun (k, v) -> (k, to_string v))
  in
  {
    id = json |> member "id" |> to_string;
    domain = json |> member "domain" |> to_string;
    operator = json |> member "operator" |> to_string;
    boundary_conditions = boundary_conditions;
    parameters =
      json |> member "parameters"
           |> to_assoc
           |> List.map (fun (name, value) -> (name, to_safe_float value));
    contracts =
      json |> member "contracts"
           |> to_list
           |> List.map parse_contract
  }

(* Parse a list of models *)
let parse_models json =
  json |> to_list |> List.map parse_model