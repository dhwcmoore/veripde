(* main.ml *)
open Yojson.Basic.Util

(* Step 1: Parse JSON input file *)
let () =
  let filename =
    if Array.length Sys.argv < 2 then (
      prerr_endline "Usage: main.exe <input.json>";
      exit 1
    ) else
      Sys.argv.(1)
  in

  let json = Yojson.Basic.from_file filename in
  let problems = to_list json in
  List.iteri
    (fun i item ->
      let id = item |> member "id" |> to_string in
      Printf.printf "✅ Problem %d: %s\n" (i + 1) id)
    problems

(* Step 2: Required to use Dynlink *)
#load "dynlink.cma";;

open Dynlink

(* 3. Define the expression AST for lambda calculus *)
type expr =
  | Var of string
  | Const of float
  | Add of expr * expr
  | Mul of expr * expr
  | Lambda of string * expr
  | Apply of expr * expr

(* 4. Lambda expression evaluator *)
let rec eval expr env =
  match expr with
  | Var x -> List.assoc x env
  | Const v -> v
  | Add (e1, e2) -> eval e1 env +. eval e2 env
  | Mul (e1, e2) -> eval e1 env *. eval e2 env
  | Lambda (x, e) -> (fun v -> eval e ((x, v) :: env))
  | Apply (e1, e2) ->
      let f = eval e1 env in
      let arg = eval e2 env in
      f arg

(* 5. Test the lambda evaluator: evaluating a function `fun x -> x * x + 2` *)
let test_lambda_evaluation () =
  let expr = Lambda("x", Add(Mul(Var("x"), Var("x")), Const(2.0))) in
  let f = eval expr [] in
  let result = f 3.0 in
  Printf.printf "Lambda evaluation result: %f\n" result

(* 6. Dynamically load the Coq-extracted OCaml code *)
let eval_dynamic_code () =
  try
    (* Load the dynamically generated file (Coq-extracted to OCaml) *)
    Printf.printf "Loading Coq-extracted PDE...\n";
    Dynlink.allow_unsafe_modules true;
    Dynlink.loadfile "pde_example.cmo";  (* Ensure this file is compiled into .cmo *)
    
    (* Retrieve the function 'pde_example' dynamically *)
    let pde_example = Dynlink.find_value "pde_example" in
    
    (* Apply the function with a test value (3.0) *)
    let result = pde_example 3.0 in
    Printf.printf "PDE evaluation result: %f\n" result
  with
  | Dynlink.Error e ->
      Printf.printf "Dynlink error: %s\n" (Dynlink.error_message e)
  | _ ->
      Printf.printf "Unexpected error during dynamic loading\n"

(* 7. Run the tests *)
let () =
  test_lambda_evaluation ();  (* Test the lambda evaluator *)
  eval_dynamic_code ()        (* Test the dynamic code loading for Coq-extracted code *)
