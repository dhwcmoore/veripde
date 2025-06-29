(* src/parsers/contract_parser.ml *)
(* Fixed to match actual constraint_types.ml *)

open Yojson.Safe.Util
open Constraint_types

(* Parse violation_severity (not validation_status) *)
let parse_violation_severity json =
  match json |> to_string with
  | "critical" -> Critical
  | "warning" -> Warning
  | _ -> Warning (* Default to warning for unknown levels *)

(* Parse bounds according to your bounds type *)
let parse_bounds json =
  let bound_type = json |> member "type" |> to_string in
  match bound_type with
  | "lower" ->
      let min_val = json |> member "value" |> to_float in
      Lower min_val
  | "upper" ->
      let max_val = json |> member "value" |> to_float in
      Upper max_val
  | "range" ->
      let min_val = json |> member "min" |> to_float in
      let max_val = json |> member "max" |> to_float in
      Range (min_val, max_val)
  | _ -> failwith ("Unknown bounds type: " ^ bound_type)

(* Parse symmetry_type *)
let parse_symmetry_type json =
  match json |> to_string with
  | "rotational" -> Rotational
  | "reflective" -> Reflective
  | "translational" -> Translational
  | _ -> failwith ("Unknown symmetry type")

(* Parse vector *)
let parse_vector json =
  let x = json |> member "x" |> to_float in
  let y = json |> member "y" |> to_float in
  let z = json |> member "z" |> to_float in
  (x, y, z)

(* Parse quantity_type *)
let parse_quantity_type json =
  match json |> to_string with
  | "mass" -> Mass
  | "energy" -> Energy
  | "momentum" -> Momentum
  | _ -> failwith ("Unknown quantity type")

(* Parse constraint according to your actual constraint_spec type *)
let parse_constraint json =
  let constraint_type = json |> member "type" |> to_string in
  let variable = json |> member "variable" |> to_string in
  
match constraint_type with
| "symmetry" ->
    let symmetry_type = json |> member "symmetry_type" |> parse_symmetry_type in
    let axis = 
      try Some (json |> member "axis" |> parse_vector)
      with _ -> None
    in
    let tolerance = json |> member "tolerance" |> to_float in
    Symmetry_Constraint { variable; symmetry_type; axis; tolerance }
| "conservation" ->
    let quantity = json |> member "quantity" |> parse_quantity_type in
    let tolerance = json |> member "tolerance" |> to_float in
    let region = Entire_Domain in (* Simplified for now *)
    Conservation_Constraint { quantity; tolerance; region }
| _ ->
    failwith ("Unknown constraint type: " ^ constraint_type)

let parse_contract json =
  let contracts = json |> member "contracts" |> to_list in
  List.map parse_constraint contracts