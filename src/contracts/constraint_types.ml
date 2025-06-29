(* src/contracts/constraint_types.ml *)

(* Core Mathematical Types *)
type vector = float * float * float

type domain_region = 
  | Entire_Domain
  | Rectangular_Region of { min : vector; max : vector }
  | Spherical_Region of { center : vector; radius : float }
  | Custom_Region of string

(* Parameter Value Types *)
type parameter_value =
  | Scalar of float
  | Vector_Value of vector
  | Field_Data of (vector -> float)
  | Matrix_Value of float list list

type model_parameters = (string * parameter_value) list

(* Constraint Specification Types *)
type symmetry_type = Rotational | Reflective | Translational

type bounds =
  | Lower of float
  | Upper of float
  | Range of (float * float)

type violation_severity = Critical | Warning

type monotonicity_direction = Increasing | Decreasing | NonDecreasing | NonIncreasing

type quantity_type = Mass | Energy | Momentum

(* Validation Result Types *)
type validation_status = Pass | Warning | Critical

type validation_result = {
  status : validation_status;
  parameter_name : string;
  actual_value : parameter_value;
  expected_constraint : string;
  violation_details : string option;
  numerical_error : float option;
  execution_time : float;
}

(* Constraint Specifications *)
type constraint_spec = 
  | Symmetry_Constraint of {
      variable : string;
      symmetry_type : symmetry_type;
      axis : vector option;
      tolerance : float;
    }
  | Bounded_Constraint of {
      variable : string;
      bounds : bounds;
      violation_severity : violation_severity;
    }
  | Monotonicity_Constraint of {
      variable : string;
      direction : monotonicity_direction;
      domain_subset : domain_region option;
    }
  | Conservation_Constraint of {
      quantity : quantity_type;
      tolerance : float;
      region : domain_region;
    }
  | Custom_Constraint of {
      name : string;
      validation_function : (model_parameters -> validation_result);
      description : string;
    }

(* Composite Types *)
type composite_constraint = {
  individual_constraints : constraint_spec list;
  interaction_rules : (constraint_spec * constraint_spec * string) list;
}

type consistency_result = 
  | Consistent
  | Inconsistent of string list
  | Unknown

(* Utility Functions *)
let string_of_vector (x, y, z) = 
  Printf.sprintf "(%g, %g, %g)" x y z

let string_of_symmetry_type = function
  | Rotational -> "rotational symmetry"
  | Reflective -> "reflective symmetry" 
  | Translational -> "translational symmetry"

let string_of_bounds = function
  | Lower min_val -> "≥ " ^ string_of_float min_val
  | Upper max_val -> "≤ " ^ string_of_float max_val
  | Range (min_val, max_val) -> 
      string_of_float min_val ^ " ≤ value ≤ " ^ string_of_float max_val

let string_of_quantity = function
  | Mass -> "mass conservation"
  | Energy -> "energy conservation"
  | Momentum -> "momentum conservation"

let string_of_validation_status = function
  | Pass -> "PASS"
  | Warning -> "WARNING"
  | Critical -> "CRITICAL"

let string_of_parameter_value = function
  | Scalar f -> string_of_float f
  | Vector_Value v -> string_of_vector v
  | Field_Data _ -> "<field data>"
  | Matrix_Value _ -> "<matrix data>"

(* Parameter extraction helpers *)
let extract_scalar_parameter param_name params =
  match List.assoc_opt param_name params with
  | Some (Scalar value) -> Some value
  | _ -> None

let extract_vector_parameter param_name params =
  match List.assoc_opt param_name params with
  | Some (Vector_Value value) -> Some value
  | _ -> None
