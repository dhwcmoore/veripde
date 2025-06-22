(* SemanticChecks.ml: Veripde semantic checks for PDE inputs *)

open Pde_problem_parser

module SemanticChecks = struct
  
  (* Check that all PDE regions are declared in the domain *)
  let all_pde_regions_declared (prob : problem) : bool =
    List.for_all
      (fun pde -> List.mem pde.region prob.domain.regions)
      prob.pdes

  (* Check that all boundary regions are declared in the domain *)
  let all_bc_regions_declared (prob : problem) : bool =
    List.for_all
      (fun (region, _) -> List.mem region prob.domain.regions)
      prob.bcs

  (* Check that only supported operators are used *)
  let supported_operators = ["laplace"; "diffusion"; "heat"]

  let all_operators_supported (prob : problem) : bool =
    List.for_all
      (fun pde -> List.mem pde.operator supported_operators)
      prob.pdes

end
