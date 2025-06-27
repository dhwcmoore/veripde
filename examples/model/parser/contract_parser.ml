open Yojson.Basic.Util
open Types

(* Parses a single clause from Yojson *)
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

(* Parses a symbolic contract from Yojson *)
let parse_contract json = {
  contract_id = json |> member "contract_id" |> to_string;
  clause = json |> member "clause" |> parse_clause;
  critical = json |> member "critical" |> to_bool;
}

(* Parses the top-level PDE model from Yojson *)
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

(* Parses a list of PDE models *)
let parse_models json =
  json |> to_list |> List.map parse_pde_model
