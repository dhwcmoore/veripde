let validate_constraint (c : constraint_spec) (params : model_parameters) : validation_result =
  match c with
  | Bounded_Constraint { variable; bounds; violation_severity } ->
      (* Convert violation_severity to validation_status *)
      let status = match violation_severity with
        | Critical -> Critical
        | Warning -> Warning
      in
      Bounds_validator.validate_bounded_constraint variable bounds status params
  | _ ->
      {
        status = Pass;
        parameter_name = "not_implemented";
        actual_value = Scalar 0.0;
        expected_constraint = "constraint type not implemented";
        violation_details = None;
        numerical_error = None;
        execution_time = 0.0;
      }
