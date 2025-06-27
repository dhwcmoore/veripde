open Types
type domain = { name : string; dimension : int };;



type pde = {
  region : string;
  operator : string;
}

type bc_type = Dirichlet | Neumann

llet cmp : Types.comparison = {

  rel = rel_op;
  lhs = lhs_expr;
  rhs = rhs_expr;
}

type problem = {
  domain : domain;
  pdes : pde list;
  bcs : boundary_condition list;
}
module PDEProblem = struct
  open Yojson.Basic.Util

  let parse_bc_type = function
    | "dirichlet" -> Dirichlet
    | "neumann" -> Neumann
    | other -> failwith ("Unknown boundary condition type: " ^ other)

  let of_json json =
    let domain_json = member "domain" json in
    let dimension = domain_json |> member "dimension" |> to_int in
    let regions = domain_json |> member "regions" |> to_list |> List.map to_string in
    let domain = { dimension; regions } in

    let pdes =
      json |> member "pde" |> to_list |> List.map (fun pde_json ->
        let region = member "region" pde_json |> to_string in
        let operator = member "operator" pde_json |> to_string in
        { region; operator }
      )
    in

    let bcs =
      json |> member "bc" |> to_list |> List.map (fun bc_entry ->
        match bc_entry with
        | `List [ `String region; `String bctype ] ->
            (region, parse_bc_type bctype)
        | _ -> failwith "Expected boundary condition as [region, type]"
      )
    in

    { domain; pdes; bcs }
end
