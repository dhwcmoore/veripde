(* main.ml *)

open Parser.Contract_parser
open Model.Types

let print_clause clause =
  match clause with
  | Requires comp ->
      Printf.printf "  Requires: %s %s %.2f\n" comp.lhs comp.rel comp.rhs
  | Within rng ->
      Printf.printf "  Within: %s ∈ [%.2f, %.2f]\n" rng.var rng.min rng.max

let print_contract (c : symbolic_contract) =
  Printf.printf "- Contract ID: %s\n" c.contract_id;
  Printf.printf "  Critical: %b\n" c.critical;
  print_clause c.clause

let print_model (m : pde_model) =
  Printf.printf "Model ID: %s\n" m.id;
  Printf.printf "Domain: %s\n" m.domain;
  Printf.printf "Operator: %s\n" m.operator

let () =
  let filename =
    if Array.length Sys.argv < 2 then (
      prerr_endline "Usage: main.exe <input.json>";
      exit 1
    ) else
      Sys.argv.(1)
  in
  
  let json = Yojson.Basic.from_file filename in
  let models = parse_models json in
  
  Printf.printf "=== VeriPDE Contract Analysis ===\n\n";
  
  List.iteri (fun i model ->
    Printf.printf "=== Model %d ===\n" (i + 1);
    print_model model;
    Printf.printf "\nContracts:\n";
    List.iter print_contract model.contracts;
    Printf.printf "\n"
  ) models