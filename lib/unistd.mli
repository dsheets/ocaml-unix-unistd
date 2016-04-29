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

module Access : sig
  type t = Unix.access_permission

  type defns = {
    r_ok : int;
    w_ok : int;
    x_ok : int;
    f_ok : int;
  }

  module Host : sig
    type t
    val of_defns : defns -> t
    val to_defns : t -> defns
  end

  val to_code : host:Host.t -> t list -> int
  val of_code : host:Host.t -> int -> t list

  val is_set : host:Host.t -> t -> int -> bool
  val set : host:Host.t -> t -> int -> int
end

module Seek : sig
  type t = SEEK_SET | SEEK_CUR | SEEK_END | SEEK_DATA | SEEK_HOLE

  type defns = {
    seek_set  : int;
    seek_cur  : int;
    seek_end  : int;
    seek_data : int option;
    seek_hole : int option;
  }

  module Host : sig
    type t
    val of_defns : defns -> t
    val to_defns : t -> defns
  end

  val to_code : host:Host.t -> t -> int option
  val of_code_exn : host:Host.t -> int -> t
  val of_code : host:Host.t -> int -> t option
end

module Sysconf : sig

  type defns = {
    pagesize : int;
  }

  module Host : sig
    type t
    val of_defns : defns -> t
    val to_defns : t -> defns
  end

  val pagesize : host:Host.t -> int
end

type host = {
  access  : Access.Host.t;
  seek    : Seek.Host.t;
  sysconf : Sysconf.Host.t;
}

