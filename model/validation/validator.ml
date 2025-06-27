(* VeriPDE Validation Module - Core Logic *)
open Yojson.Basic.Util

type validation_status = 
  | Pass 
  | Warning 
  | Critical 
  | Unknown

type validation_result = {
  parameter: string;
  value: float;
  status: validation_status;
  message: string;
}

type model_validation = {
  model_id: string;
  validations: validation_result list;
  overall_status: validation_status;
  expected_status: validation_status option;
}

type threshold_config = {
  temp_max: float;
  disp_max: float;
  pressure_max: float;
  mass_min: float;
}

let validate_parameter name value config =
  match name with
  | "mass" -> 
    if value <= config.mass_min then 
      (Critical, Printf.sprintf "❌ mass invalid (≤ %.3f)" config.mass_min)
    else (Pass, "✔ mass valid")
  | "temperature" -> 
    if value < 0.0 then (Critical, "❌ temperature < 0")
    else if value > config.temp_max then (Warning, "⚠️ temperature > max")
    else (Pass, "✔ temperature in range")
  | "pressure" -> 
    if value < 0.0 then (Critical, "❌ pressure < 0") 
    else if value > config.pressure_max then (Warning, "⚠️ pressure > max")
    else (Pass, "✔ pressure valid")
  | "displacement" -> 
    if value < 0.0 then (Critical, "❌ displacement < 0")
    else if value > config.disp_max then (Warning, "⚠️ displacement > max")
    else (Pass, "✔ displacement in range")
  | _ -> (Pass, Printf.sprintf "✔ %s valid" name)

let validate_model_parameters model_json config =
  let model_id = model_json |> member "model_id" |> to_string in
  let parameters = model_json |> member "parameters" |> to_assoc in
  let expected = try
    Some (match model_json |> member "expected_result" |> to_string with
      | "PASS" -> Pass
      | "WARNING" -> Warning  
      | "CRITICAL_FAILURE" -> Critical
      | _ -> Unknown)
  with _ -> None in
  
  let validations = List.map (fun (name, value_json) ->
    let value = match value_json with
      | `Float f -> f
      | `Int i -> float_of_int i
      | _ -> failwith ("Invalid value for parameter: " ^ name) in
    let (status, message) = validate_parameter name value config in
    { parameter = name; value; status; message }
  ) parameters in
  
  let overall_status = 
    if List.exists (fun v -> v.status = Critical) validations then Critical
    else if List.exists (fun v -> v.status = Warning) validations then Warning
    else Pass in
  
  { model_id; validations; overall_status; expected_status = expected }

let status_to_string = function
  | Pass -> "PASS"
  | Warning -> "WARNING" 
  | Critical -> "CRITICAL"
  | Unknown -> "UNKNOWN"

let status_icon = function
  | Pass -> "✅"
  | Warning -> "⚠️"
  | Critical -> "❌" 
  | Unknown -> "❓"

let display_validation_result result =
  Printf.printf "\n=== Model: %s ===\n" result.model_id;
  Printf.printf "📊 Parameter Validation:\n";
  
  List.iter (fun v ->
    Printf.printf "  %s %s = %.3f | %s\n" 
      (status_icon v.status) v.parameter v.value v.message
  ) result.validations;
  
  Printf.printf "\n🎯 Overall Status: %s %s" 
    (status_icon result.overall_status) 
    (status_to_string result.overall_status);
  
  (match result.expected_status with
  | Some expected ->
    if result.overall_status = expected then
      Printf.printf " ✅ (matches expected)\n"
    else
      Printf.printf " ❌ (expected %s)\n" (status_to_string expected)
  | None -> Printf.printf "\n");
  
  Printf.printf "%s\n" (String.make 50 '-')
