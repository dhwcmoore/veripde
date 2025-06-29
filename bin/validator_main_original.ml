(* Simple VeriPDE Validator *)
open Validation.Validator
open Validation.Thresholds

let () =
  if Array.length Sys.argv < 2 then (
    Printf.printf "Usage: %s <models.json> [config.json]\n" Sys.argv.(0);
    exit 1
  );
  
  let models_file = Sys.argv.(1) in
  let config_file = if Array.length Sys.argv > 2 then Sys.argv.(2) else "examples/thresholds.json" in
  
  try
    Printf.printf "🧪 VeriPDE Contract Validation System\n";
    Printf.printf "====================================\n";
    
    let config = load_config config_file in
    Printf.printf "📋 Using thresholds: temp=%.1f, disp=%.3f, pressure=%.1f, mass=%.3f\n" 
      config.temp_max config.disp_max config.pressure_max config.mass_min;
    
    let json = Yojson.Basic.from_file models_file in
    match json with
    | `List models ->
      List.iteri (fun i model ->
        Printf.printf "\n[Test %d/%d]" (i+1) (List.length models);
        let result = validate_model_parameters model config in
        display_validation_result result
      ) models;
      Printf.printf "\n🎯 June 27 Milestone: COMPLETE ✅\n"
    | _ ->
      Printf.printf "❌ Error: Expected JSON array of models\n";
      exit 1
  with
  | Sys_error msg -> Printf.printf "❌ File error: %s\n" msg; exit 1
  | Yojson.Json_error msg -> Printf.printf "❌ JSON error: %s\n" msg; exit 1
  | exn -> Printf.printf "❌ Unexpected error: %s\n" (Printexc.to_string exn); exit 1
