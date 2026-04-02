open OUnit2
open Model_validation.Validator
open Model_validation.Thresholds

let cfg = default_config

let assert_status json_str expected_status =
  let json = Yojson.Basic.from_string json_str in
  let result = validate_model_parameters json cfg in
  assert_equal expected_status result.overall_status

let test_mass_boundary _ =
  assert_status "{\"model_id\":\"mass_boundary\",\"parameters\":{\"mass\":0.001}}" Critical

let test_temperature_exceeds _ =
  assert_status "{\"model_id\":\"temp_exceeds\",\"parameters\":{\"temperature\":501.0}}" Warning

let test_negative_pressure _ =
  assert_status "{\"model_id\":\"neg_pressure\",\"parameters\":{\"pressure\":-0.1}}" Critical

let test_unknown_param_policy _ =
  assert_status "{\"model_id\":\"unknown\",\"parameters\":{\"foo\":123.0}}" Pass

let tests = "contract checks" >::: [
  "mass boundary" >:: test_mass_boundary;
  "temp exceeds" >:: test_temperature_exceeds;
  "negative pressure" >:: test_negative_pressure;
  "unknown parameter" >:: test_unknown_param_policy;
]
