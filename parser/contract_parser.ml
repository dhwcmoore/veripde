(* parser/contract_parser.ml *)

open Yojson.Basic.Util
open Model.Types
open Json_utils

(* Parse a clause from JSON *)
let parse_clause json =
  let clause_type = json |> member "type" |> to_string in
  if clause_type = "requires" then
    let c = {
      rel = json |> member "rel" |> to_string;
      lhs = json |> member "lhs" |> to_string;
      rhs = json |> member "rhs" |> to_safe_float;
    } in
    Requires c
  else if clause_type = "within" then
    let r = {
      var = json |> member "var" |> to_string;
      min = json |> member "min" |> to_safe_float;
      max = json |> member "max" |> to_safe_float;
    } in
    Within r
  else
    failwith "Unknown clause type"

(* Parse a symbolic contract from JSON *)
let parse_contract json = {
  contract_id = json |> member "contract_id" |> to_string;
  clause = json |> member "clause" |> parse_clause;
  critical = json |> member "critical" |> to_bool;
}

(* Parse a PDE model from JSON *)
let parse_model json = {
  id = json |> member "id" |> to_string;
  domain = json |> member "domain" |> to_string;
  operator = json |> member "operator" |> to_string;
  boundary_conditions =
    json |> member "boundary_conditions"
         |> to_list
         |> List.map (fun pair ->
              match pair with
              | `List [ `String k; `String v ] -> (k, v)
              | _ -> failwith "Invalid boundary condition format"
            );
  parameters =
    json |> member "parameters"
         |> to_list
         |> List.map (fun pair ->
              match pair with
              | `List [ `String name; (`Int _ | `Float _) as num ] ->
                  (name, to_safe_float num)
              | _ -> failwith "Invalid parameter format"
            );
  contracts =
    json |> member "contracts"
         |> to_list
         |> List.map parse_contract;
}

(* Parse a list of models *)
let parse_models json =
  json |> to_list |> List.map parse_model
