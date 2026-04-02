(* bin/validator_main.ml - VeriPDE validator executable *)

open Model_validation.Validator
open Model_validation.Thresholds

let usage_and_exit () =
  Printf.printf "Usage: %s validate <models.json> [--thresholds config.json] [--output json|text]\n" Sys.argv.(0);
  exit 1

let parse_args () =
  let args = Array.to_list Sys.argv |> List.tl in
  match args with
  | "validate" :: filename :: rest ->
    let output_json = ref false in
    let config_file = ref None in
    let rec loop = function
      | [] -> ()
      | "--output" :: "json" :: tl -> output_json := true; loop tl
      | "--output" :: "text" :: tl -> output_json := false; loop tl
      | "--thresholds" :: f :: tl -> config_file := Some f; loop tl
      | _ -> usage_and_exit ()
    in
    loop rest;
    (filename, !config_file, !output_json)
  | _ -> usage_and_exit ()

let model_validation_to_yojson result =
  `Assoc [
    ("model_id", `String result.model_id);
    ("overall_status", `String (status_to_string result.overall_status));
    ("validations", `List (List.map (fun v ->
      `Assoc [
        ("parameter", `String v.parameter);
        ("value", `Float v.value);
        ("status", `String (status_to_string v.status));
        ("message", `String v.message)
      ]
    ) result.validations));
    ("expected_status", match result.expected_status with
      | Some s -> `String (status_to_string s)
      | None -> `Null)
  ]

let run () =
  let (models_file, threshold_file, output_json) = parse_args () in
  let config = match threshold_file with
    | Some path -> load_config path
    | None -> default_config
  in
  try
    let json = Yojson.Basic.from_file models_file in
    let models =
      match json with
      | `List l -> l
      | `Assoc _ as obj -> [obj]
      | _ -> failwith "Expected JSON object or array of objects"
    in

    let results = List.map (fun model ->
      let result = validate_model_parameters model config in
      display_validation_result result;
      result
    ) models in

    if output_json then (
      let out = `List (List.map model_validation_to_yojson results) in
      print_endline (Yojson.Basic.pretty_to_string out)
    );

    if List.exists (fun r -> r.overall_status = Critical) results then exit 2 else exit 0
  with
  | Sys_error msg -> Printf.eprintf "❌ File error: %s\n" msg; exit 1
  | Yojson.Json_error msg -> Printf.eprintf "❌ JSON error: %s\n" msg; exit 1
  | Failure msg -> Printf.eprintf "❌ Validation error: %s\n" msg; exit 1
  | exn -> Printf.eprintf "❌ Unexpected error: %s\n" (Printexc.to_string exn); exit 1

let () =
  if Array.length Sys.argv = 1 then usage_and_exit ();
  run ()

