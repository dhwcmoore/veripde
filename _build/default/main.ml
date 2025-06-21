open Yojson.Basic.Util

let () =
  let filename =
    if Array.length Sys.argv < 2 then (
      prerr_endline "Usage: main.exe <input.json>";
      exit 1
    ) else
      Sys.argv.(1)
  in

  Printf.printf "[🔍] Loading file: %s\n%!" filename;

  let json = Yojson.Basic.from_file filename in

  let problems = to_list json in
  Printf.printf "[✅] Parsed %d problems\n%!" (List.length problems);

  List.iteri
    (fun i item ->
      let id = item |> member "id" |> to_string in
      Printf.printf "🔹 Problem %d: id = %s\n%!" (i + 1) id)
    problems
