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

  type defns = {
    r_ok : int;
    w_ok : int;
    x_ok : int;
    f_ok : int;
  }

  module Host = struct
    type t = defns
    let of_defns d = d
    and to_defns d = d
  end

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

  let of_code ~host code = List.filter
    (fun t -> is_set ~host t code)
    Unix.([R_OK ; W_OK ; X_OK ; F_OK])

end

module Seek = struct
  type t = SEEK_SET | SEEK_CUR | SEEK_END | SEEK_DATA | SEEK_HOLE

  type defns = {
    seek_set  : int;
    seek_cur  : int;
    seek_end  : int;
    seek_data : int option;
    seek_hole : int option;
  }

  type index = (int, t) Hashtbl.t

  module Host = struct
    type t = defns * index

    let index_of_defns defns =
      let open Hashtbl in
      let h = create 10 in
      replace h defns.seek_set  SEEK_SET;
      replace h defns.seek_cur  SEEK_CUR;
      replace h defns.seek_end  SEEK_END;
      (match defns.seek_data with Some i -> replace h i SEEK_DATA | None -> ());
      (match defns.seek_hole with Some i -> replace h i SEEK_HOLE | None -> ());
      h

    let of_defns d = (d, index_of_defns d)
    and to_defns (d, _) = d
  end

  let to_code ~host = let (defns,_) = host in function
    | SEEK_SET  -> Some defns.seek_set
    | SEEK_CUR  -> Some defns.seek_cur
    | SEEK_END  -> Some defns.seek_end
    | SEEK_DATA -> defns.seek_data
    | SEEK_HOLE -> defns.seek_hole

  let of_code_exn ~host code =
    let (_,index) = host in
    Hashtbl.find index code

  let of_code ~host code =
    try Some (of_code_exn ~host code) with Not_found -> None
end

module Sysconf = struct
  type defns = {
    pagesize : int;
  }

  module Host = struct
    type t = defns
    let of_defns d = d
    and to_defns d = d
  end

  let pagesize ~host = host.pagesize
end

type host = {
  access  : Access.Host.t;
  seek    : Seek.Host.t;
  sysconf : Sysconf.Host.t;
}
