(* main.ml *)

(* Required to use Dynlink *)
#load "dynlink.cma";;

open Dynlink

(* 1. Define the expression AST for lambda calculus *)
type expr =
  | Var of string
  | Const of float
  | Add of expr * expr
  | Mul of expr * expr
  | Lambda of string * expr
  | Apply of expr * expr

(* 2. Lambda expression evaluator *)
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

(* 3. Test the lambda evaluator: evaluating a function `fun x -> x * x + 2` *)
let test_lambda_evaluation () =
  let expr = Lambda("x", Add(Mul(Var("x"), Var("x")), Const(2.0))) in
  let f = eval expr [] in
  let result = f 3.0 in
  Printf.printf "Lambda evaluation result: %f\n" result

(* 4. Dynamically load the Coq-extracted OCaml code *)
let eval_dynamic_code () =
  try
    Printf.printf "Loading Coq-extracted PDE...\n";
    Dynlink.allow_unsafe_modules true;
    Dynlink.loadfile "pde_example.cmo";
    let pde_example = Obj.magic (Topfind.load_value "Pde_example.pde_example") in
    let result = pde_example 3.0 in
    Printf.printf "PDE evaluation result: %f\n" result
  with
  | Dynlink.Error e ->
      Printf.printf "Dynlink error: %s\n" (Dynlink.error_message e)
  | _ ->
      Printf.printf "Unexpected error during dynamic loading\n"

(* 5. Run the tests *)
let () =
  test_lambda_evaluation ();
  eval_dynamic_code ()
