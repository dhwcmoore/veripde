(* main.ml *)

open Model                    (* contains pde_model, symbolic_contract, etc. *)
open Parser.Contract_parser  (* contains parse_models *)

let print_clause clause =
  match clause with
  | Model.Types.Requires { rel; lhs; rhs } ->
      Printf.printf "  Requires: %s %s %.2f\n" lhs rel rhs
  | Model.Types.Within { var; min; max } ->
      Printf.printf "  Within: %s ∈ [%.2f, %.2f]\n" var min max

let print_contract (c : Model.Types.symbolic_contract) =
  Printf.printf "- Contract ID: %s\n" c.contract_id;
  Printf.printf "  Critical: %b\n" c.critical;
  print_clause c.clause
let print_model (m : Types.pde_model) =
  Printf.printf "Model ID: %s\n" m.id;
  Printf.printf "Domain: %s\n" m.domain;
  Printf.printf "Operator: %s\n" m.operator;
  Printf.printf "Boundary Conditions:\n";
  List.iter (fun (loc, kind) ->
    Printf.printf "  %s: %s\n" loc kind
  ) m.boundary_conditions;
  Printf.printf "Parameters:\n";
  List.iter (fun (param, value) ->
    Printf.printf "  %s = %.2f\n" param value
  ) m.parameters;
  Printf.printf "Contracts (%d):\n" (List.length m.contracts);
  List.iter print_contract m.contracts;
  print_endline "----"

let () =
  let json_file = "examples/pde_with_contracts.json" in
  let data = Yojson.Basic.from_file json_file in
  let models : Types.pde_model list = parse_models data in
  List.iter print_model models
