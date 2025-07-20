(* Main driver for Graydon DSL compiler *)

let read_file filename =
  let ic = open_in filename in
  let len = in_channel_length ic in
  let buf = Bytes.create len in
  really_input ic buf 0 len;
  close_in ic;
  Bytes.to_string buf

let compile_file input_file output_file =
  Printf.printf "Compiling %s to %s\n" input_file output_file;
  
  (* Read input file *)
  let content = read_file input_file in
  
  (* Create lexer buffer *)
  let lexbuf = Lexing.from_string content in
  Lexing.set_filename lexbuf input_file;
  
  (* Parse the file *)
  let ast = Parser.file Lexer.token lexbuf in
  
  (* Build semantic model *)
  let (env, rules) = Semantic.build_semantic_model ast in
  
  (* Generate OCaml code *)
  let ocaml_file = 
    try Filename.chop_extension output_file ^ ".ml"
    with Invalid_argument _ -> output_file ^ ".ml" in
  Codegen.write_ocaml_file ocaml_file env rules;
  
  (* Compile OCaml to executable *)
  let compile_cmd = 
    Printf.sprintf "ocamlc -o %s unix.cma -I +unix %s" output_file ocaml_file
  in
  let status = Sys.command compile_cmd in
  
  if status = 0 then begin
    Printf.printf "Successfully compiled %s\n" output_file;
    (* Don't clean up for debugging *)
    (* if Sys.file_exists ocaml_file then Sys.remove ocaml_file *)
  end else begin
    Printf.eprintf "Failed to compile OCaml code\n";
    Printf.eprintf "File %s contains:\n" ocaml_file;
    let ic = open_in ocaml_file in
    let content = really_input_string ic (in_channel_length ic) in
    close_in ic;
    Printf.eprintf "%s\n" content;
    exit 1
  end

let usage () =
  Printf.eprintf "Usage: %s <makefile> [output]\n" Sys.argv.(0);
  exit 1

let () =
  if Array.length Sys.argv < 2 then usage ();
  
  let input_file = Sys.argv.(1) in
  let output_file = 
    if Array.length Sys.argv > 2 then Sys.argv.(2)
    else Filename.chop_extension input_file ^ ".exe"
  in
  
  compile_file input_file output_file