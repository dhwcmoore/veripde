(* src/validation/bounds_validator.ml *)

open Constraint_types

let check_bounds bounds value =
  match bounds with
  | Lower min_val -> value >= min_val
  | Upper max_val -> value <= max_val  
  | Range (min_val, max_val) -> value >= min_val && value <= max_val

let validate_bounded_constraint variable bounds severity params =
  let start_time = Sys.time () in
  
  match List.assoc_opt variable params with
  | None -> 
      {
        status = Critical;
        parameter_name = variable;
        actual_value = Scalar 0.0;
        expected_constraint = string_of_bounds bounds;
        violation_details = Some ("Parameter '" ^ variable ^ "' not found");
        numerical_error = None;
        execution_time = Sys.time () -. start_time;
      }
  | Some (Scalar value) ->
      let passes = check_bounds bounds value in
      if passes then
        {
          status = Pass;
          parameter_name = variable;
          actual_value = Scalar value;
          expected_constraint = string_of_bounds bounds;
          violation_details = None;
          numerical_error = None;
          execution_time = Sys.time () -. start_time;
        }
      else
        (* Use if-then-else instead of pattern matching to avoid the warning *)
        let result_status = 
          if severity = Critical then Critical else Warning
        in
        {
          status = result_status;
          parameter_name = variable;
          actual_value = Scalar value;
          expected_constraint = string_of_bounds bounds;
          violation_details = Some ("Value " ^ string_of_float value ^ " violates bounds " ^ string_of_bounds bounds);
          numerical_error = None;
          execution_time = Sys.time () -. start_time;
        }
  | Some other -> 
      {
        status = Critical;
        parameter_name = variable;
        actual_value = other;
        expected_constraint = string_of_bounds bounds;
        violation_details = Some "Parameter type not supported for bounds checking";
        numerical_error = None;
        execution_time = Sys.time () -. start_time;
      }
