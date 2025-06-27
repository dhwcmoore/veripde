open OUnit2
(* open Yojson.Basic *)
open Parser.Json_utils


let test_to_safe_float _ =
  let float_json = `Float 3.14 in
  let int_json = `Int 42 in
  let non_number_json = `String "oops" in

  assert_equal 3.14 (to_safe_float float_json);
  assert_equal 42.0 (to_safe_float int_json);
  assert_raises
    (Yojson.Basic.Util.Type_error("Expected int or float", non_number_json))
    (fun () -> to_safe_float non_number_json)

let suite =
  "Json_utils tests" >::: [
    "to_safe_float handles float and int" >:: test_to_safe_float
  ]

let () =
  run_test_tt_main suite
