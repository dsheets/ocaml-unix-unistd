module Access = struct
  include Unix_unistd_common.Access

  let view ~host = Ctypes.(view ~read:(of_code ~host) ~write:(to_code ~host) int)
end

module Sysconf = struct
  include Unix_unistd_common.Sysconf
end

open Ctypes
open Foreign
open Unsigned

(** Can raise Unix.Unix_error *)
let write =
  let c = foreign ~check_errno:true "write"
    PosixTypes.(int @-> ptr void @-> size_t @-> returning size_t) in
  fun fd buf count ->
    Size_t.to_int (c (Fd_send_recv.int_of_fd fd) buf (Size_t.of_int count))

(** Can raise Unix.Unix_error *)
let read =
  let c = foreign ~check_errno:true "read"
    PosixTypes.(int @-> ptr void @-> size_t @-> returning size_t) in
  fun fd buf count ->
    Size_t.to_int (c (Fd_send_recv.int_of_fd fd) buf (Size_t.of_int count))
