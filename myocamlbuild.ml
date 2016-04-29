open Ocamlbuild_plugin;;
open Ocamlbuild_pack;;

let ctypes_libdir = Sys.getenv "CTYPES_LIB_DIR" in
let ocaml_libdir = Sys.getenv "OCAML_LIB_DIR" in
let lwt_libdir = try Sys.getenv "LWT_LIB_DIR" with Not_found -> "" in

dispatch begin
  function
  | After_rules ->
    rule "cstubs: lib_gen/x_types_detect.c -> x_types_detect"
      ~prods:["lib_gen/%_types_detect"]
      ~deps:["lib_gen/%_types_detect.c"]
      (fun env build ->
         Cmd (S[A"cc";
                A("-I"); A ctypes_libdir;
                A("-I"); A ocaml_libdir;
                A"-o";
                A(env "lib_gen/%_types_detect");
                A(env "lib_gen/%_types_detect.c");
               ]));

    rule "cstubs: lib_gen/x_types_detect -> unix/x_types_detected.ml"
      ~prods:["unix/%_types_detected.ml"]
      ~deps:["lib_gen/%_types_detect"]
      (fun env build ->
         Cmd (S[A(env "lib_gen/%_types_detect");
                Sh">";
                A(env "unix/%_types_detected.ml");
               ]));

    rule "cstubs: lib_gen/x_types.ml -> x_types_detect.c"
      ~prods:["lib_gen/%_types_detect.c"]
      ~deps: ["lib_gen/%_typegen.byte"]
      (fun env build ->
         Cmd (A(env "lib_gen/%_typegen.byte")));

    copy_rule "cstubs: lib_gen/x_types.ml -> unix/x_types.ml"
      "lib_gen/%_types.ml" "unix/%_types.ml";

    flag ["c"; "compile"; "use_lwt"] & S[A"-I"; A lwt_libdir];
    flag ["c"; "compile"; "use_ctypes"] & S[A"-I"; A ctypes_libdir];

    (* Linking C stubs *)
    flag ["ocaml"; "link"; "byte"; "library"; "use_unix_unistd_stubs"] &
      S[A"-dllib"; A"-lunix_unistd_stubs"];
    flag ["ocaml"; "link"; "byte"; "library"; "use_unistd_lwt_stubs"] &
      S[A"-dllib"; A"-lunix_unistd_lwt_stubs"];

    flag ["ocaml"; "link"; "native"; "library"; "use_unix_unistd_stubs"] &
      S[A"-cclib"; A"-lunix_unistd_stubs"];
    flag ["ocaml"; "link"; "native"; "library"; "use_unistd_lwt_stubs"] &
      S[A"-cclib"; A"-lunix_unistd_lwt_stubs"];

  | _ -> ()
end;;
