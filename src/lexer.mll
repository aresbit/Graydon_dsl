{
  open Parser
  open Lexing

  let incr_line lexbuf = 
    let pos = lexbuf.lex_curr_p in
    lexbuf.lex_curr_p <- { pos with 
      pos_lnum = pos.pos_lnum + 1;
      pos_bol = pos.pos_cnum;
    }

  let errorf fmt =
    let b = Buffer.create 17 in
    let f = Format.formatter_of_buffer b in
    Format.kfprintf (fun _ -> failwith (Buffer.contents b)) f fmt

  let lex_error lexbuf msg =
    let pos = lexbuf.lex_curr_p in
    errorf "%s:%d:%d: %s" pos.pos_fname pos.pos_lnum (pos.pos_cnum - pos.pos_bol) msg
}

let blank = [' ' '\t' '\r']
let newline = '\n' | "\r\n"
let comment = '#' [^ '\n' '\r']*

let var = ['a'-'z' 'A'-'Z' '_']['a'-'z' 'A'-'Z' '_' '0'-'9']*
let word = [^ ' ' '\t' '\n' '\r' '$' ':' '#' '@' '<' '^' '\\' '=' '(' ')' ]+
let special = '$' | '@' | '<' | '^'
let dollar = '$' '(' var ')'

rule token = parse
  | blank+ { token lexbuf }
  | newline { incr_line lexbuf; token lexbuf }
  | comment { token lexbuf }
  | "=" { EQUAL }
  | ":" { COLON }
  | "\\" newline { incr_line lexbuf; token lexbuf }
  | "\\" { BACKSLASH }
  | dollar { VAR(Lexing.lexeme lexbuf) }
  | special { SPEC(Lexing.lexeme lexbuf) }
  | var { WORD(Lexing.lexeme lexbuf) }
  | word { WORD(Lexing.lexeme lexbuf) }
  | eof { EOF }