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

  type host
  val to_code : host:host -> t list -> int
  val host : host
  val of_code : host:host -> int -> t list

  val is_set : host:host -> t -> int -> bool
  val set : host:host -> t -> int -> int
end

module Seek : sig
  type t = SEEK_SET | SEEK_CUR | SEEK_END | SEEK_DATA | SEEK_HOLE

  type host
  val to_code : host:host -> t -> int option
  val host : host
  val of_code_exn : host:host -> int -> t
  val of_code : host:host -> int -> t option
end

module Sysconf : sig
  type host

  val host : host

  val pagesize : host:host -> int
end

type host = {
  access  : Access.host;
  seek    : Seek.host;
  sysconf : Sysconf.host;
}
val host : host
