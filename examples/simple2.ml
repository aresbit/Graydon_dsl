(* Auto-generated Makefile DSL compiler output *)
open Sys
open Unix

type file = string
and actions = string list
and rule = Rule of (file * file list * actions)

let rec newer a b =
  try
    let st_a = Unix.stat a in
    let st_b = Unix.stat b in
    st_a.Unix.st_mtime > st_b.Unix.st_mtime
  with Unix.Unix_error _ -> true

let run cmd =
  Printf.printf "Running: %s\n" cmd;
  let status = Sys.command cmd in
  if status <> 0 then failwith (Printf.sprintf "Command failed: %s" cmd)

let exists file =
  try Sys.file_exists file && not (Sys.is_directory file)
  with Sys_error _ -> false

let needs_update target deps =
  not (exists target) || List.exists (fun dep -> not (exists dep) || newer dep target) deps

let execute_rule (Rule (target, deps, actions)) =
  if needs_update target deps then begin
    List.iter run actions
  end


let () =
  let rules = [
    Rule ("program", ["main.c"; "utils.c"], [])
  ] in
  List.iter execute_rule rules