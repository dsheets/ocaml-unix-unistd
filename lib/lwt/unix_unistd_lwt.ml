let (>>=) = Lwt.(>>=)

external lwt_pread_c_memory_job :
  Unix.file_descr -> _ -> len:int -> offset:int64 -> int Lwt_unix.job
  = "unix_unistd_lwt_pread_c_memory_job"

external lwt_pwrite_c_memory_job :
  Unix.file_descr -> _ -> len:int -> offset:int64 -> int Lwt_unix.job
  = "unix_unistd_lwt_pwrite_c_memory_job"

module type S =
sig
  (** Can raise Unix.Unix_error *)
  val pread_lwt : ?blocking:bool ->
    Unix.file_descr -> unit Ctypes.ptr -> int -> int64 -> int Lwt.t
    
  (** Can raise Unix.Unix_error *)
  val pwrite_lwt : ?blocking:bool ->
    Unix.file_descr -> unit Ctypes.ptr -> int -> int64 -> int Lwt.t
end

module Make
    (X:
     sig
       val pread : Unix.file_descr -> unit Ctypes.ptr -> int -> int64 -> int
       val pwrite : Unix.file_descr -> unit Ctypes.ptr -> int -> int64 -> int
     end) : S =
struct
  let pread_lwt ?blocking fd (Ctypes_static.CPointer ptr as p) len offset =
    let lwt_fd = Lwt_unix.of_unix_file_descr ?blocking fd in
    Lwt_unix.blocking lwt_fd >>= function
    | true ->
      Lwt_unix.wait_read lwt_fd >>= fun () ->
      Lwt_unix.run_job (lwt_pread_c_memory_job fd ptr ~len ~offset)
    | false ->
      Lwt_unix.(wrap_syscall Read) lwt_fd @@ fun () ->
      X.pread fd p len offset

  let pwrite_lwt ?blocking fd (Ctypes_static.CPointer ptr as p) len offset =
    let lwt_fd = Lwt_unix.of_unix_file_descr ?blocking fd in
    Lwt_unix.blocking lwt_fd >>= function
    | true ->
      Lwt_unix.wait_write lwt_fd >>= fun () ->
      Lwt_unix.run_job (lwt_pwrite_c_memory_job fd ptr ~len ~offset)
    | false ->
      Lwt_unix.(wrap_syscall Write) lwt_fd @@ fun () ->
      X.pwrite fd p len offset
end
