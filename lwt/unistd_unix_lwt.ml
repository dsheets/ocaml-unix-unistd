let (>>=) = Lwt.(>>=)

module Gen = Unix_unistd_lwt_generated
module C = Unix_unistd_bindings.C(Unix_unistd_lwt_generated)

module type S =
sig
  (** Can raise Unix.Unix_error *)
  val write_lwt : ?blocking:bool ->
    Unix.file_descr -> unit Ctypes.ptr -> int -> int Lwt.t

  (** Can raise Unix.Unix_error *)
  val pwrite_lwt : ?blocking:bool ->
    Unix.file_descr -> unit Ctypes.ptr -> int -> int64 -> int Lwt.t

  (** Can raise Unix.Unix_error *)
  val read_lwt : ?blocking:bool ->
    Unix.file_descr -> unit Ctypes.ptr -> int -> int Lwt.t

  (** Can raise Unix.Unix_error *)
  val pread_lwt : ?blocking:bool ->
    Unix.file_descr -> unit Ctypes.ptr -> int -> int64 -> int Lwt.t
end

let char_bigarray_of_unit_ptr p len =
  let open Ctypes in
  bigarray_of_ptr array1 len Bigarray.char
    (coerce (ptr void) (ptr char) p)

let write ?blocking fd ptr len =
  let lwt_fd = Lwt_unix.of_unix_file_descr ?blocking fd in
  Lwt_bytes.write lwt_fd (char_bigarray_of_unit_ptr ptr len) 0 len

open Posix_types

let pwrite ?blocking fd (Ctypes_static.CPointer ptr as p) len offset =
  let lwt_fd = Lwt_unix.of_unix_file_descr ?blocking fd in
  Lwt_unix.blocking lwt_fd >>= function
  | true ->
    Lwt_unix.wait_write lwt_fd >>= fun () ->
    (C.pwrite fd p (Size.of_int len) (Off.of_int64 offset)).Gen.lwt >>= fun (rv, errno) ->
    if rv < Ssize.zero
    then Errno_unix.raise_errno ~call:"pwrite" errno
    else Lwt.return (Ssize.to_int rv)
  | false ->
    Lwt_unix.(wrap_syscall Write) lwt_fd @@ fun () ->
    Unistd_unix.pwrite fd p len offset

let read ?blocking fd ptr len =
  let lwt_fd = Lwt_unix.of_unix_file_descr ?blocking fd in
  Lwt_bytes.read lwt_fd (char_bigarray_of_unit_ptr ptr len) 0 len

let pread ?blocking fd (Ctypes_static.CPointer ptr as p) len offset =
  let lwt_fd = Lwt_unix.of_unix_file_descr ?blocking fd in
  Lwt_unix.blocking lwt_fd >>= function
  | true ->
    Lwt_unix.wait_read lwt_fd >>= fun () ->
    (C.pread fd p (Size.of_int len) (Off.of_int64 offset)).Gen.lwt >>= fun (rv, errno) ->
    if rv < Ssize.zero
    then Errno_unix.raise_errno ~call:"pread" errno
    else Lwt.return (Ssize.to_int rv)
  | false ->
    Lwt_unix.(wrap_syscall Read) lwt_fd @@ fun () ->
    Unistd_unix.pread fd p len offset

