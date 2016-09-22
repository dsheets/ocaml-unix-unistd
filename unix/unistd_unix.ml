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

module Type = Unix_unistd_types.C(Unix_unistd_types_detected)
module C = Unix_unistd_bindings.C(Unix_unistd_generated)

module Access = struct
  open Unistd.Access

  let host = Host.of_defns Type.Access.({ r_ok; w_ok; x_ok; f_ok })
  let view ~host = Ctypes.(view ~read:(of_code ~host) ~write:(to_code ~host) int)
end

module Seek = struct
  open Unistd.Seek

  let host =
    Host.of_defns Type.Seek.({
        seek_set;
        seek_cur;
        seek_end;
        seek_data = if seek_data = -1 then None else Some seek_data;
        seek_hole = if seek_hole = -1 then None else Some seek_hole;
      })
end

module Sysconf = struct
  open Unistd.Sysconf

  let host = Host.of_defns Type.Sysconf.({ pagesize = _sc_pagesize })
end

let host = {
  Unistd.access = Access.host;
  seek          = Seek.host;
  sysconf       = Sysconf.host;
}

open Ctypes
open Posix_types

(* Filesystem functions *)

let handle_error ?label call zero (rv, errno) =
  if rv < zero
  then Errno_unix.raise_errno ~call ?label errno
  else rv

let seek_code cmd = match Unistd.Seek.to_code ~host:Seek.host cmd with
  | Some code -> code
  | None -> raise Unix.(Unix_error (EINVAL,"lseek",""))

let lseek fd offset whence =
  Off.to_int64
    (handle_error "lseek" Off.zero
       (C.lseek fd (Off.of_int64 offset) (seek_code whence)))

let unlink path =
  ignore (handle_error "unlink" 0 ~label:path (C.unlink path))

let rmdir path =
  ignore (handle_error "rmdir" 0 ~label:path (C.rmdir path))

let write fd buf count =
  Ssize.to_int
    (handle_error "write" Ssize.zero (C.write fd buf (Size.of_int count)))

let pwrite fd buf count offset =
  Ssize.to_int
    (handle_error "pwrite" Ssize.zero
       (C.pwrite fd buf (Size.of_int count) (Off.of_int64 offset)))

let read fd buf count =
  Ssize.to_int
    (handle_error "read" Ssize.zero (C.read fd buf (Size.of_int count)))

let pread fd buf count offset =
  Ssize.to_int
    (handle_error "pread" Ssize.zero
       (C.pread fd buf (Size.of_int count) (Off.of_int64 offset)))

let close fd =
  ignore (handle_error "close" 0 (C.close fd))
    
let access pathname mode =
  ignore
    (handle_error "access" 0 ~label:pathname
       (C.access pathname (Unistd.Access.to_code ~host:Access.host mode)))

let readlink =
  let c' path buf sz =
    handle_error "readlink" Ssize.zero ~label:path
      (C.readlink path buf sz) 
  in
  fun path ->
    let sz = ref (Unistd.Sysconf.pagesize ~host:Sysconf.host) in
    let buf = ref (allocate_n char ~count:!sz) in
    let len = ref (Ssize.to_int (c' path !buf (Size.of_int !sz))) in
    while !len = !sz do
      sz  := !sz * 2;
      buf := allocate_n char ~count:!sz;
      len := Ssize.to_int (c' path !buf (Size.of_int !sz))
    done;
    CArray.(set (from_ptr !buf (!len+1)) !len (Char.chr 0));
    coerce (ptr char) string !buf

let symlink target linkpath =
  ignore (handle_error ~label:linkpath "symlink" 0 (C.symlink target linkpath))

let truncate path length =
  ignore
    (handle_error "truncate" ~label:path 0
       (C.truncate path (Off.of_int64 length)))

let ftruncate fd length =
  ignore
    (handle_error "truncate" 0 (C.ftruncate fd (Off.of_int64 length)))

let chown path owner group =
  ignore
    (handle_error "chown" 0 ~label:path
       (C.chown path (Uid.of_int owner) (Gid.of_int group)))

let fchown fd owner group =
  ignore
    (handle_error "fchown" 0
       (C.fchown fd (Uid.of_int owner) (Gid.of_int group)))

(* Process functions *)

let seteuid euid =
  ignore (handle_error "seteuid" 0 (C.seteuid (Posix_types.Uid.of_int euid)))

let setegid egid =
  ignore (handle_error "setguid" 0 (C.setegid (Posix_types.Gid.of_int egid)))
