%{ 
  open Ast

  let errorf fmt =
    let b = Buffer.create 17 in
    let f = Format.formatter_of_buffer b in
    Format.kfprintf (fun _ -> failwith (Buffer.contents b)) f fmt

  let parse_error msg =
    errorf "Parse error: %s" msg
%}

%token EQUAL COLON BACKSLASH EOF
%token <string> WORD VAR SPEC

%start file
%type <Ast.t> file

%%

file:
  | stmts EOF { $1 }
;

stmts:
  | { [] }
  | stmt stmts { $1 :: $2 }
;

stmt:
  | var_assign { $1 }
  | rule { $1 }
;

var_assign:
  | WORD EQUAL words { Assign($1, $3) }
;

rule:
  | target COLON deps actions { Rule($1, $3, $4) }
;

target:
  | WORD { $1 }
  | VAR { $1 }
  | SPEC { $1 }
;

deps:
  | { [] }
  | dep deps { $1 :: $2 }
;

dep:
  | WORD { $1 }
  | VAR { $1 }
  | SPEC { $1 }
;

actions:
  | { [] }
  | action actions { $1 :: $2 }
;

action:
  | WORD { $1 }
  | VAR { $1 }
  | SPEC { $1 }
  | BACKSLASH { "\\" }
;

words:
  | { [] }
  | word words { $1 :: $2 }
;

word:
  | WORD { Word($1) }
  | VAR { Var($1) }
  | SPEC { Spec($1) }
;