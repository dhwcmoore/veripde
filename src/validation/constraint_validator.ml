(* src/validation/constraint_validator.ml *)

open Constraint_types
open Symmetry_validator
open Bounds_validator

let get_float_param params param_name = 
  match List.assoc_opt param_name params with
  | Some (Scalar value) -> value
  | _ -> failwith ("Parameter '" ^ param_name ^ "' not found or not a scalar")

let pass_result () = {
  status = Pass;
  parameter_name = "";
  actual_value = Scalar 0.0;
  expected_constraint = "";
  violation_details = None;
  numerical_error = None;
  execution_time = 0.001;
}

let violation_result severity message = {
  status = severity;
  parameter_name = "validation";
  actual_value = Scalar 0.0;
  expected_constraint = "constraint validation";
  violation_details = Some message;
  numerical_error = None;
  execution_time = 0.001;
}
let get_field_values params variable =
  match List.assoc_opt variable params with
  | Some (Field_Data field_func) -> field_func
  | Some (Scalar value) -> (fun _ -> value) (* Convert scalar to constant field *)
  | Some (Vector_Value (x, y, z)) -> (fun (px, py, pz) -> x *. px +. y *. py +. z *. pz) (* Simple dot product *)
  | _ -> failwith ("Field data for variable '" ^ variable ^ "' not found")


let warning_result param_name actual_val expected_constraint details = {
  status = Warning;
  parameter_name = param_name;
  actual_value = actual_val;
  expected_constraint = expected_constraint;
  violation_details = Some details;
  numerical_error = None;
  execution_time = 0.001;
}

let critical_result param_name actual_val expected_constraint details = {
  status = Critical;
  parameter_name = param_name;
  actual_value = actual_val;
  expected_constraint = expected_constraint;
  violation_details = Some details;
  numerical_error = None;
  execution_time = 0.001;
}
(* Vector and matrix utilities for symmetry checks *)
module MathUtils = struct
  let vector_magnitude (x, y, z) = sqrt (x *. x +. y *. y +. z *. z)

  let vector_normalize v =
    let mag = vector_magnitude v in
    if mag < 1e-12 then (0.0, 0.0, 1.0) else let (x, y, z) = v in (x /. mag, y /. mag, z /. mag)

  let vector_dot (x1, y1, z1) (x2, y2, z2) = x1 *. x2 +. y1 *. y2 +. z1 *. z2

  let vector_cross (x1, y1, z1) (x2, y2, z2) =
    (y1 *. z2 -. z1 *. y2, z1 *. x2 -. x1 *. z2, x1 *. y2 -. y1 *. x2)

  let rotation_matrix_z angle =
    let cos_a = cos angle in
    let sin_a = sin angle in
    [[cos_a; -.sin_a; 0.0];
     [sin_a;  cos_a; 0.0];
     [0.0;    0.0;   1.0]]

  let apply_matrix matrix (x, y, z) =
    match matrix with
    | [[m11; m12; m13]; [m21; m22; m23]; [m31; m32; m33]] ->
        (m11 *. x +. m12 *. y +. m13 *. z,
         m21 *. x +. m22 *. y +. m23 *. z,
         m31 *. x +. m32 *. y +. m33 *. z)
    | _ -> failwith "Invalid matrix shape"
end

(* Custom validator registry *)
module CustomConstraintRegistry = struct
  let registry = Hashtbl.create 10

  let register_constraint name description fn =
    Hashtbl.replace registry name (description, fn)

  let get_validator name =
    match Hashtbl.find_opt registry name with
    | Some (_, fn) -> Some fn
    | None -> None

  let describe name =
    match Hashtbl.find_opt registry name with
    | Some (desc, _) -> Some desc
    | None -> None
end

(* Built-in custom constraints *)
let validate_reynolds_number params =
  try
    let velocity = get_float_param params "velocity" in
    let density = get_float_param params "density" in
    let viscosity = get_float_param params "viscosity" in
    let length = get_float_param params "characteristic_length" in
    let re = (density *. velocity *. length) /. viscosity in
    if re < 2300.0 then pass_result ()
    else violation_result Critical "Reynolds number indicates turbulent flow"
  with Not_found -> violation_result Critical "Missing parameters for Reynolds number"

let validate_cfl_condition params =
  try
    let dt = get_float_param params "time_step" in
    let dx = get_float_param params "spatial_step" in
    let c = get_float_param params "wave_speed" in
    let cfl = (c *. dt) /. dx in
    if cfl <= 1.0 then pass_result ()
    else violation_result Critical "CFL condition violated"
  with Not_found -> violation_result Critical "Missing parameters for CFL"

let validate_stress_safety_factor params =
  try
    let stress = get_float_param params "stress" in
    let yield = get_float_param params "yield_strength" in
    let factor = yield /. stress in
    if factor >= 2.0 then pass_result ()
    else violation_result Critical "Safety factor < 2.0"
  with Not_found -> violation_result Critical "Missing stress/yield_strength"

let () =
  CustomConstraintRegistry.register_constraint "reynolds_number" "Check Reynolds number" validate_reynolds_number;
  CustomConstraintRegistry.register_constraint "cfl_condition" "Check CFL condition" validate_cfl_condition;
  CustomConstraintRegistry.register_constraint "stress_safety_factor" "Safety factor ≥ 2.0" validate_stress_safety_factor

(* Dispatch constraint validation *)
let validate_constraint (spec : constraint_spec) (params : model_parameters) : validation_result =
  match spec with
  | Symmetry_Constraint { variable; symmetry_type; axis; tolerance } ->
      let field_values = get_field_values params variable in
      begin match symmetry_type with
      | Rotational ->
          let is_valid = validate_rotational_symmetry ~field_values ~tolerance in
          if is_valid then pass_result ()
          else violation_result Critical "Rotational symmetry violated"
      | Reflective ->
          let is_valid = validate_reflection_symmetry ~field_values ~axis ~tolerance in
          if is_valid then pass_result ()
          else violation_result Critical "Reflective symmetry violated"
      | Translational ->
          let is_valid = validate_translation_symmetry ~field_values ~axis ~tolerance in
          if is_valid then pass_result ()
          else violation_result Critical "Translational symmetry violated"
      end
  | Bounded_Constraint { variable; bounds; violation_severity } ->
      let status =
        match violation_severity with
        | Critical -> Critical
        | Warning -> Warning
      in
      let result = validate_bounded_constraint variable bounds status params in
      result
  | Monotonicity_Constraint _ -> failwith "Monotonicity constraint not implemented"
  | Conservation_Constraint _ -> failwith "Conservation constraint not implemented"
  | Custom_Constraint { name; validation_function = _; _ } ->
      (match CustomConstraintRegistry.get_validator name with
       | Some fn -> fn params
       | None -> violation_result Critical ("Unknown custom constraint: " ^ name))

let compose_constraints (_specs : constraint_spec list) : composite_constraint =
  (* Placeholder for real implementation *)
  failwith "compose_constraints not yet implemented"

let check_constraint_consistency (_specs : constraint_spec list) : consistency_result =
  (* Placeholder for real implementation *)
  failwith "check_constraint_consistency not yet implemented"
