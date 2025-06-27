#!/bin/bash

# VeriPDE Validation System Setup - June 27, 2025
# Run this from your veripde/ directory

echo "🚀 VeriPDE Validation System Setup"
echo "=================================="
echo "📅 Date: $(date)"
echo ""

# Verify we're in the right directory
if [ ! -d "model" ] || [ ! -d "examples" ]; then
    echo "❌ Error: Please run this from your veripde/ directory"
    echo "   Expected to see: model/, examples/, docs/, ocaml/ directories"
    exit 1
fi

echo "✅ Found VeriPDE directory structure"

# Create validation module directory
echo "📁 Creating validation module..."
mkdir -p model/validation

# Create the validation library dune file
echo "📝 Creating validation dune configuration..."
cat > model/validation/dune << 'DUNE_EOF'
(library
 (public_name veripde.validation)
 (name validation)
 (libraries yojson model))
DUNE_EOF

# Create thresholds configuration
echo "📝 Creating threshold configuration..."
cat > examples/thresholds.json << 'JSON_EOF'
{
  "temp_max": 500.0,
  "disp_max": 0.1,
  "pressure_max": 100.0,
  "mass_min": 0.001,
  "description": "VeriPDE Contract Validation Thresholds",
  "version": "1.0",
  "last_updated": "2025-06-27"
}
JSON_EOF

# Create simple test for immediate verification
echo "📝 Creating simple test model..."
cat > examples/simple_validation_test.json << 'SIMPLE_EOF'
[
  {
    "model_id": "basic_valid",
    "domain": "unit_square",
    "operator": "heat",
    "parameters": {
      "mass": 1.0,
      "temperature": 25.0
    },
    "contracts": [],
    "expected_result": "PASS"
  },
  {
    "model_id": "basic_invalid",
    "domain": "unit_square",
    "operator": "heat", 
    "parameters": {
      "mass": -0.5,
      "temperature": 600.0
    },
    "contracts": [],
    "expected_result": "CRITICAL_FAILURE"
  }
]
SIMPLE_EOF

# Create validation module files
echo "�� Creating core validation module..."

# Validator.ml
cat > model/validation/validator.ml << 'VAL_EOF'
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
VAL_EOF

# Thresholds.ml
cat > model/validation/thresholds.ml << 'THRESH_EOF'
(* VeriPDE Threshold Configuration Management *)
open Validator
open Yojson.Basic.Util

let default_config = {
  temp_max = 500.0;
  disp_max = 0.1;
  pressure_max = 100.0;
  mass_min = 0.001;
}

let load_config filename =
  try
    let json = Yojson.Basic.from_file filename in
    {
      temp_max = json |> member "temp_max" |> to_float;
      disp_max = json |> member "disp_max" |> to_float;
      pressure_max = json |> member "pressure_max" |> to_float_option |> Option.value ~default:100.0;
      mass_min = json |> member "mass_min" |> to_float_option |> Option.value ~default:0.001;
    }
  with
  | Sys_error _ -> 
    Printf.printf "⚠️ Config file not found, using defaults\n";
    default_config
  | exn ->
    Printf.printf "⚠️ Config error: %s, using defaults\n" (Printexc.to_string exn);
    default_config
THRESH_EOF

echo ""
echo "✅ Setup Complete!"
echo ""
echo "📋 Created Files:"
echo "   📁 model/validation/ (new validation module)"
echo "   �� model/validation/validator.ml"
echo "   📄 model/validation/thresholds.ml"
echo "   📄 model/validation/dune"
echo "   📄 examples/thresholds.json"
echo "   📄 examples/simple_validation_test.json"
echo ""
echo "⏭️ Next Steps:"
echo "   1. Test the build: dune build"
echo "   2. Add validation to your main.ml"
echo "   3. Test: dune exec ./ocaml/main.exe examples/simple_validation_test.json"
echo ""
echo "🎯 Ready for June 27 milestone completion!"
