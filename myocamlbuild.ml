open Ocamlbuild_plugin;;
open Ocamlbuild_pack;;

dispatch begin
  function
  | After_rules ->
    flag ["c"; "compile"] & S[A"-ccopt"; A"-I/usr/local/include"];
    flag ["c"; "ocamlmklib"] & A"-L/usr/local/lib";
    flag ["ocaml"; "link"; "native"; "program"] &
      S[A"-cclib"; A"-L/usr/local/lib"];

    (* Linking C stubs *)
    flag ["ocaml"; "link"; "byte"; "library"; "use_unistd_stubs"] &
      S[A"-dllib"; A"-lunistd_stubs"];
    flag ["ocaml"; "link"; "byte"; "library"; "use_unix_unistd_stubs"] &
      S[A"-dllib"; A"-lunix_unistd_stubs"];
    flag ["ocaml"; "link"; "byte"; "library"; "use_unistd_lwt_stubs"] &
      S[A"-dllib"; A"-lunix_unistd_lwt_stubs"];

    flag ["ocaml"; "link"; "native"; "library"; "use_unistd_stubs"] &
      S[A"-cclib"; A"-lunistd_stubs"];
    flag ["ocaml"; "link"; "native"; "library"; "use_unix_unistd_stubs"] &
      S[A"-cclib"; A"-lunix_unistd_stubs"];
    flag ["ocaml"; "link"; "native"; "library"; "use_unistd_lwt_stubs"] &
      S[A"-cclib"; A"-lunix_unistd_lwt_stubs"];

  | _ -> ()
end;;
