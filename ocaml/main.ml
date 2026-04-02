(* OCaml CLI tool for validating JSON inputs against formal Coq definitions *)

open Yojson.Basic.Util
open Validator
open Thresholds

let () =
  Printf.printf "Info: ocaml/main.ml is deprecated; use veripde-validator on bin/\n";
  Printf.printf "To run with models: veripde-validator validate <file.json>\n";
  ()

