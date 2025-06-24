(* parser/json_utils.ml *)
(* open Yojson.Basic *)

let to_safe_float (json : Yojson.Basic.t) : float =
  match json with
  | `Int i -> float_of_int i
  | `Float f -> f
  | _ -> raise (Yojson.Basic.Util.Type_error("Expected int or float", json))
