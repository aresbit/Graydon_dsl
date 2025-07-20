(* Abstract Syntax Tree for Makefile DSL *)

type expr = 
  | Word of string
  | Var of string
  | Spec of string

and stmt = 
  | Assign of string * expr list
  | Rule of string * string list * string list

type t = stmt list

(* Helper functions *)
let[@warning "-39"] rec string_of_expr = function
  | Word s -> s
  | Var s -> "$" ^ s
  | Spec s -> s

let string_of_stmt = function
  | Assign (name, exprs) -> 
      name ^ " = " ^ String.concat " " (List.map string_of_expr exprs)
  | Rule (target, deps, actions) -> 
      target ^ ": " ^ String.concat " " deps ^ "\n\t" ^ 
      String.concat "; " actions

let string_of_program stmts =
  String.concat "\n" (List.map string_of_stmt stmts)