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
  val host : Unistd.Access.Host.t
  val view : host:Unistd.Access.Host.t -> Unistd.Access.t list Ctypes.typ
end

module Seek : sig
  val host : Unistd.Seek.Host.t
end

module Sysconf : sig
  val host : Unistd.Sysconf.Host.t
end

val host : Unistd.host

(** Filesystem functions *)

(** Can raise Unix.Unix_error *)
val lseek : Unix.file_descr -> int64 -> Unistd.Seek.t -> int64

(** Can raise Unix.Unix_error *)
val unlink : string -> unit

(** Can raise Unix.Unix_error *)
val rmdir : string -> unit

(** Can raise Unix.Unix_error *)
val write : Unix.file_descr -> unit Ctypes.ptr -> int -> int

(** Can raise Unix.Unix_error *)
val pwrite : Unix.file_descr -> unit Ctypes.ptr -> int -> int64 -> int

(** Can raise Unix.Unix_error *)
val read : Unix.file_descr -> unit Ctypes.ptr -> int -> int

(** Can raise Unix.Unix_error *)
val pread : Unix.file_descr -> unit Ctypes.ptr -> int -> int64 -> int

(** Can raise Unix.Unix_error *)
val close : Unix.file_descr -> unit

(** Can raise Unix.Unix_error *)
val access : string -> Unistd.Access.t list -> unit

(** Can raise Unix.Unix_error *)
val readlink : string -> string

(** Can raise Unix.Unix_error *)
val symlink : string -> string -> unit

(** Can raise Unix.Unix_error *)
val truncate : string -> int64 -> unit

(** Can raise Unix.Unix_error *)
val ftruncate : Unix.file_descr -> int64 -> unit

(** Can raise Unix.Unix_error *)
val chown : string -> int -> int -> unit

(** Can raise Unix.Unix_error *)
val fchown : Unix.file_descr -> int -> int -> unit

(** Process functions *)

(** Can raise Unix.Unix_error *)
val seteuid : int -> unit

(** Can raise Unix.Unix_error *)
val setegid : int -> unit
