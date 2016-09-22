open Ocamlbuild_plugin;;
open Ocamlbuild_pack;;

let ctypes_libdir = Sys.getenv "CTYPES_LIB_DIR" in
let lwt_libdir = Sys.getenv "LWT_LIB_DIR" in
let ocaml_libdir = Sys.getenv "OCAML_LIB_DIR" in

dispatch begin
  function
  | After_rules ->
    Ctypes_rules.rules ~prefix:"unistd"
      ~ctypes_libdir ~lwt_libdir ~ocaml_libdir ()
  | _ -> ()
end;;
