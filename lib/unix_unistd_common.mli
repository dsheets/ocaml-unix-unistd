module Access : sig
  type t = Unix.access_permission

  type host
  val to_code : host:host -> t list -> int
  val host : host
  val of_code : host:host -> int -> t list

  val is_set : host:host -> t -> int -> bool
  val set : host:host -> t -> int -> int
end

module Sysconf : sig
  type host

  val host : host

  val pagesize : host:host -> int
end

