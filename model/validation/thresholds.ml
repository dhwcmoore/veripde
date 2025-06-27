(* VeriPDE Threshold Configuration Management *)
open Validator
open Yojson.Basic.Util

let default_config = {
  temp_max = 500.0;
  disp_max = 0.1;
  pressure_max = 100.0;
  mass_min = 0.001;
}

let load_config filename =
  try
    let json = Yojson.Basic.from_file filename in
    {
      temp_max = json |> member "temp_max" |> to_float;
      disp_max = json |> member "disp_max" |> to_float;
      pressure_max = json |> member "pressure_max" |> to_float_option |> Option.value ~default:100.0;
      mass_min = json |> member "mass_min" |> to_float_option |> Option.value ~default:0.001;
    }
  with
  | Sys_error _ -> 
    Printf.printf "⚠️ Config file not found, using defaults\n";
    default_config
  | exn ->
    Printf.printf "⚠️ Config error: %s, using defaults\n" (Printexc.to_string exn);
    default_config
