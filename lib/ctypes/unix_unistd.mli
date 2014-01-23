module Access : sig
  include module type of Unix_unistd_common.Access

  val view : host:host -> t list Ctypes.typ
end

module Sysconf : sig
  include module type of Unix_unistd_common.Sysconf
end

(** Can raise Unix.Unix_error *)
val write : Unix.file_descr -> unit Ctypes.ptr -> int -> int

(** Can raise Unix.Unix_error *)
val read : Unix.file_descr -> unit Ctypes.ptr -> int -> int

(** Can raise Unix.Unix_error *)
val close : Unix.file_descr -> unit
