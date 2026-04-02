(* test/test_runner.ml - VeriPDE test suite *)
[@@@warning "-32-33-34-27"]

open OUnit2
open Test_validator
open Test_contracts

let test_cli_smoke _ =
  let command = "dune exec --root /data/veripde veripde-validator -- validate examples/validator_smoke.json --thresholds examples/thresholds.json --output text" in
  let rc = Sys.command command in
  assert_equal 0 rc

let () =
  let suite = "veripde suite" >::: [
    Test_validator.tests;
    Test_contracts.tests;
    "cli_smoke" >:: test_cli_smoke;
  ] in
  run_test_tt_main suite

