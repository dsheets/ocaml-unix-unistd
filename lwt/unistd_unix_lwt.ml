let (>>=) = Lwt.(>>=)

external lwt_pwrite_c_memory_job :
  Unix.file_descr -> _ -> len:int -> offset:int64 -> int Lwt_unix.job
  = "unix_unistd_lwt_pwrite_c_memory_job"

external lwt_pread_c_memory_job :
  Unix.file_descr -> _ -> len:int -> offset:int64 -> int Lwt_unix.job
  = "unix_unistd_lwt_pread_c_memory_job"

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

let pwrite ?blocking fd (Ctypes_static.CPointer ptr as p) len offset =
  let lwt_fd = Lwt_unix.of_unix_file_descr ?blocking fd in
  Lwt_unix.blocking lwt_fd >>= function
  | true ->
    Lwt_unix.wait_write lwt_fd >>= fun () ->
    Lwt_unix.run_job (lwt_pwrite_c_memory_job fd ptr ~len ~offset)
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
    Lwt_unix.run_job (lwt_pread_c_memory_job fd ptr ~len ~offset)
  | false ->
    Lwt_unix.(wrap_syscall Read) lwt_fd @@ fun () ->
    Unistd_unix.pread fd p len offset

