let (>>=) = Lwt.(>>=)

external lwt_pread_c_memory_job :
  Unix.file_descr -> _ -> len:int -> offset:int64 -> int Lwt_unix.job
  = "unix_unistd_lwt_pread_c_memory_job"

external lwt_pwrite_c_memory_job :
  Unix.file_descr -> _ -> len:int -> offset:int64 -> int Lwt_unix.job
  = "unix_unistd_lwt_pwrite_c_memory_job"

let pread_lwt fd (Ctypes_static.CPointer ptr) len offset : int Lwt.t =
  let lwt_fd = Lwt_unix.of_unix_file_descr fd in
  Lwt_unix.wait_read lwt_fd >>= fun () ->
  Lwt_unix.run_job (lwt_pread_c_memory_job fd ptr ~len ~offset)

let pwrite_lwt fd (Ctypes_static.CPointer ptr) len offset : int Lwt.t =
  let lwt_fd = Lwt_unix.of_unix_file_descr fd in
  Lwt_unix.wait_write lwt_fd >>= fun () ->
  Lwt_unix.run_job (lwt_pwrite_c_memory_job fd ptr ~len ~offset)
