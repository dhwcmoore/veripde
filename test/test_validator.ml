open OUnit2
open Model_validation.Validator
open Model_validation.Thresholds

let default_cfg = default_config

let parse_json s = Yojson.Basic.from_string s

let test_basic_pass _ =
  let json = parse_json "{\"model_id\":\"simple_heat_equation\",\"parameters\":{\"mass\":1.5,\"temperature\":25.0},\"expected_result\":\"PASS\"}" in
  let result = validate_model_parameters json default_cfg in
  assert_equal Pass result.overall_status;
  assert_equal (Some Pass) result.expected_status;
  assert_equal "simple_heat_equation" result.model_id

let test_warning_temperature _ =
  let json = parse_json "{\"model_id\":\"hot_model\",\"parameters\":{\"mass\":1.5,\"temperature\":600.0},\"expected_result\":\"WARNING\"}" in
  let result = validate_model_parameters json default_cfg in
  assert_equal Warning result.overall_status;
  assert_equal (Some Warning) result.expected_status

let test_critical_pressure _ =
  let json = parse_json "{\"model_id\":\"bad_pressure\",\"parameters\":{\"mass\":1.5,\"temperature\":25.0,\"pressure\":-3.0},\"expected_result\":\"CRITICAL_FAILURE\"}" in
  let result = validate_model_parameters json default_cfg in
  assert_equal Critical result.overall_status;
  assert_equal (Some Critical) result.expected_status

let test_unknown_parameter _ =
  let json = parse_json "{\"model_id\":\"unknown_param\",\"parameters\":{\"foo\":10.0},\"expected_result\":\"PASS\"}" in
  let result = validate_model_parameters json default_cfg in
  assert_equal Pass result.overall_status;
  assert_equal (Some Pass) result.expected_status

let test_invalid_type _ =
  let json = parse_json "{\"model_id\":\"invalid_type\",\"parameters\":{\"mass\":\"bad\"}}" in
  assert_raises (Failure "Invalid value for parameter: mass") (fun () -> validate_model_parameters json default_cfg)

let tests = "validator tests" >::: [
  "basic_pass" >:: test_basic_pass;
  "temperature_warning" >:: test_warning_temperature;
  "pressure_critical" >:: test_critical_pressure;
  "unknown_parameter" >:: test_unknown_parameter;
  "invalid_type" >:: test_invalid_type;
]
