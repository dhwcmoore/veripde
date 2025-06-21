open Pde_problem_parser
open SemanticChecks

let () =
  let filename =
    if Array.length Sys.argv < 2 then (
      prerr_endline "Usage: main.exe <input.json>";
      exit 1
    ) else
      Sys.argv.(1)
  in

  Printf.printf "[🔍] Loading file: %s\n%!" filename;

  let json =
    try Yojson.Basic.from_file filename
    with e ->
      Printf.eprintf "[ERROR] Cannot load JSON: %s\n" (Printexc.to_string e);
      exit 1
  in

  Printf.printf "[✅] Loaded JSON.\n%!";

 let problem =
  try PDEProblem.of_json json
  with e ->
    Printf.eprintf "[ERROR] Failed to parse PDEProblem: %s\n" (Printexc.to_string e);
    exit 1
in

let module SC = SemanticChecks in

let results = [
  ("PDE regions declared", SC.all_pde_regions_declared problem);
  ("BC regions declared", SC.all_bc_regions_declared problem);
  ("Operators supported", SC.all_operators_supported problem)
] in

List.iter (fun (label, ok) ->
  Printf.printf "[%s] %s\n" (if ok then "✅" else "❌") label
) results;


  Printf.printf "[✅] Successfully parsed PDE problem.\n%!";
  (* Continue with validation... *)
