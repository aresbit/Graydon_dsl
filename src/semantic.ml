module StringMap = Map.Make(String)
(* Semantic model for Makefile DSL *)

(* Types for the semantic model *)
type file = string

and actions = string list

and rule = Rule of (file * file list * actions)

and var_def = 
  | VarLiteral of string list
  | VarRef of string
  | VarConcat of var_def list

and env = var_def StringMap.t

(* Semantic analysis *)
let rec eval_var (env : env) (var : var_def) : string list =
  match var with
  | VarLiteral l -> l
  | VarRef name -> 
      (match StringMap.find_opt name env with
      | Some v -> eval_var env v
      | None -> [])
  | VarConcat vars ->
      List.flatten (List.map (eval_var env) vars)

(* Convert AST to semantic model *)
(* 移除了未使用的 'rec' 标志 *)
let expr_to_var_def (expr : Ast.expr) : var_def =
  match expr with
  | Ast.Word s -> VarLiteral [s]
  | Ast.Var s -> VarRef s
  | Ast.Spec s -> VarLiteral [s]

(* 移除了未使用的 'rec' 标志 *)
let exprs_to_var_def (exprs : Ast.expr list) : var_def =
  match exprs with
  | [] -> VarLiteral []
  | [e] -> expr_to_var_def e
  | es -> VarConcat (List.map expr_to_var_def es)

(* Build semantic model from AST *)
let build_semantic_model (stmts : Ast.t) : (env * rule list) =
  let rec build env rules = function
    | [] -> (env, List.rev rules)
    | stmt :: rest ->
        match stmt with
        | Ast.Assign (name, exprs) ->
            let var_def = exprs_to_var_def exprs in
            let new_env = StringMap.add name var_def env in
            build new_env rules rest
        | Ast.Rule (target, deps, actions) ->
            (*
              修复后的解析器直接为 target, deps, 和 actions 提供了 string 和 string list，
              这与语义模型中的 `rule` 类型完全匹配，简化了这里的逻辑。
            *)
            let rule = Rule (target, deps, actions) in
            build env (rule :: rules) rest
  in
  build StringMap.empty [] stmts

(* Dependency graph analysis *)
let build_dependency_graph (rules : rule list) : (file, file list) Hashtbl.t =
  let graph = Hashtbl.create 17 in
  List.iter (fun (Rule (target, deps, _)) ->
    Hashtbl.add graph target deps
  ) rules;
  graph

(* Topological sort for dependencies *)
let topological_sort (graph : (file, file list) Hashtbl.t) : file list =
  let visited = Hashtbl.create 17 in
  let temp = Hashtbl.create 17 in
  let result = ref [] in
  
  let rec visit file =
    if Hashtbl.mem temp file then
      failwith (Printf.sprintf "Circular dependency involving %s" file)
    else if not (Hashtbl.mem visited file) then begin
      Hashtbl.add temp file ();
      let deps = try Hashtbl.find graph file with Not_found -> [] in
      List.iter visit deps;
      Hashtbl.remove temp file;
      Hashtbl.add visited file ();
      result := file :: !result
    end
  in
  
  Hashtbl.iter (fun file _ -> visit file) graph;
  List.rev !result