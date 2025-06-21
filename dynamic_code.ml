open Dynlink;;

let eval_dynamic_code () =
  try
    (* Load the dynamically generated file *)
    let _ = loadfile "dynamic_code.ml" in
    let pde_example = Dynlink.find_value "pde_example" in
    (* Apply the function with a test value *)
    let result = pde_example 3.0 in
    Printf.printf "Result: %f\n" result
  with
  | Dynlink.Error e -> Printf.printf "Error: %s\n" (Dynlink.error_message e)
  | _ -> Printf.printf "Unexpected error\n";;
type expr =
  | Var of string
  | Const of float
  | Add of expr * expr
  | Mul of expr * expr
  | Lambda of string * expr
  | Apply of expr * expr

let rec eval expr env =
  match expr with
  | Var x -> List.assoc x env
  | Const v -> v
  | Add (e1, e2) -> eval e1 env +. eval e2 env
  | Mul (e1, e2) -> eval e1 env *. eval e2 env
  | Lambda (x, e) -> (fun v -> eval e ((x, v) :: env))
  | Apply (e1, e2) -> let f = eval e1 env in
                      let arg = eval e2 env in
                      f arg
Extraction "pde_example.ml" pde_example.
