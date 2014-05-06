(*
 * Copyright (c) 2014 David Sheets <sheets@alum.mit.edu>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 *)

module Access = struct
  type t = Unix.access_permission

  external r_ok : unit -> int = "unix_unistd_r_ok" "noalloc"
  external w_ok : unit -> int = "unix_unistd_w_ok" "noalloc"
  external x_ok : unit -> int = "unix_unistd_x_ok" "noalloc"
  external f_ok : unit -> int = "unix_unistd_f_ok" "noalloc"

  type defns = {
    r_ok : int;
    w_ok : int;
    x_ok : int;
    f_ok : int;
  }

  type host = defns

  let _to_code ~host = let defns = host in Unix.(function
    | R_OK -> defns.r_ok
    | W_OK -> defns.w_ok
    | X_OK -> defns.x_ok
    | F_OK -> defns.f_ok
  )

  let is_set ~host t =
    let bit = _to_code ~host t in
    fun code -> (bit land code) = bit
  let set ~host t =
    let bit = _to_code ~host t in
    fun code -> bit lor code

  let to_code ~host = List.fold_left (fun code t -> set ~host t code) 0

  let host =
    let defns = {
      r_ok = r_ok ();
      w_ok = w_ok ();
      x_ok = x_ok ();
      f_ok = f_ok ();
    } in
    defns

  let of_code ~host code = List.filter
    (fun t -> is_set ~host t code)
    Unix.([R_OK ; W_OK ; X_OK ; F_OK])

end

module Sysconf = struct
  external pagesize : unit -> int = "unix_unistd_pagesize" "noalloc"

  type host = {
    pagesize : int;
  }

  let host = {
    pagesize = pagesize ();
  }

  let pagesize ~host = host.pagesize
end

type host = {
  access  : Access.host;
  sysconf : Sysconf.host;
}
let host = {
  access  = Access.host;
  sysconf = Sysconf.host;
}
