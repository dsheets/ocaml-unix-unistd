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

module Access = struct
  include Unix_unistd_common.Access

  let view ~host = Ctypes.(view ~read:(of_code ~host) ~write:(to_code ~host) int)
end

module Seek = struct
  include Unix_unistd_common.Seek
end

module Sysconf = struct
  include Unix_unistd_common.Sysconf
end

type host = {
  access  : Access.host;
  seek    : Seek.host;
  sysconf : Sysconf.host;
}
let host = {
  access  = Access.host;
  seek    = Seek.host;
  sysconf = Sysconf.host;
}

open Ctypes
open Foreign
open Unsigned

let local ?check_errno addr typ =
  coerce (ptr void) (funptr ?check_errno typ) (ptr_of_raw_address addr)

let to_off_t = coerce int64_t PosixTypes.off_t

module Uid = UInt
let uid_t = uint
module Gid = UInt
let gid_t = uint

let fd = Fd_send_recv.(view ~read:fd_of_int ~write:int_of_fd int)

(* Filesystem functions *)

external unix_unistd_lseek_ptr : unit -> nativeint = "unix_unistd_lseek_ptr"

let lseek =
  let cmd =
    let write cmd = match Seek.(to_code ~host cmd) with
      | Some code -> code
      | None -> raise Unix.(Unix_error (EINVAL,"lseek",""))
    in
    Ctypes.(view ~read:Seek.(of_code_exn ~host) ~write int)
  in
  let c = local ~check_errno:true (unix_unistd_lseek_ptr ())
    PosixTypes.(fd @-> off_t @-> cmd @-> returning off_t)
  in
  fun fd offset whence ->
    let offset = to_off_t offset in
    try coerce PosixTypes.off_t int64_t (c fd offset whence)
    with Unix.Unix_error(e,_,_) -> raise (Unix.Unix_error (e,"lseek",""))

external unix_unistd_unlink_ptr : unit -> nativeint = "unix_unistd_unlink_ptr"

let unlink =
  let c = local ~check_errno:true (unix_unistd_unlink_ptr ())
    PosixTypes.(string @-> returning int)
  in
  fun pathname ->
    try ignore (c pathname)
    with Unix.Unix_error(e,_,_) -> raise (Unix.Unix_error (e,"unlink",pathname))

external unix_unistd_rmdir_ptr : unit -> nativeint = "unix_unistd_rmdir_ptr"

let rmdir =
  let c = local ~check_errno:true (unix_unistd_rmdir_ptr ())
    PosixTypes.(string @-> returning int)
  in
  fun pathname ->
    try ignore (c pathname)
    with Unix.Unix_error(e,_,_) -> raise (Unix.Unix_error (e,"rmdir",pathname))

external unix_unistd_write_ptr : unit -> nativeint = "unix_unistd_write_ptr"

let write =
  let c = local ~check_errno:true (unix_unistd_write_ptr ())
    PosixTypes.(fd @-> ptr void @-> size_t @-> returning size_t)
  in
  fun fd buf count ->
    try
      Size_t.to_int (c fd buf (Size_t.of_int count))
    with Unix.Unix_error(e,_,_) -> raise (Unix.Unix_error (e,"write",""))

external unix_unistd_pwrite_ptr : unit -> nativeint = "unix_unistd_pwrite_ptr"

let pwrite =
  let c = local ~check_errno:true (unix_unistd_pwrite_ptr ())
    PosixTypes.(fd @-> ptr void @-> size_t @-> off_t @-> returning size_t)
  in
  fun fd buf count offset ->
    let offset = to_off_t offset in
    try
      Size_t.to_int (c fd buf (Size_t.of_int count) offset)
    with Unix.Unix_error(e,_,_) -> raise (Unix.Unix_error (e,"pwrite",""))

external unix_unistd_read_ptr : unit -> nativeint = "unix_unistd_read_ptr"

let read =
  let c = local ~check_errno:true (unix_unistd_read_ptr ())
    PosixTypes.(fd @-> ptr void @-> size_t @-> returning size_t)
  in
  fun fd buf count ->
    try
      Size_t.to_int (c fd buf (Size_t.of_int count))
    with Unix.Unix_error(e,_,_) -> raise (Unix.Unix_error (e,"read",""))

external unix_unistd_pread_ptr : unit -> nativeint = "unix_unistd_pread_ptr"

let pread =
  let c = local ~check_errno:true (unix_unistd_pread_ptr ())
    PosixTypes.(fd @-> ptr void @-> size_t @-> off_t @-> returning size_t)
  in
  fun fd buf count offset ->
    let offset = to_off_t offset in
    try
      Size_t.to_int (c fd buf (Size_t.of_int count) offset)
    with Unix.Unix_error(e,_,_) -> raise (Unix.Unix_error (e,"pread",""))

external unix_unistd_close_ptr : unit -> nativeint = "unix_unistd_close_ptr"

let close =
  let c = local ~check_errno:true (unix_unistd_close_ptr ())
    PosixTypes.(fd @-> returning int)
  in
  fun fd ->
    try ignore (c fd)
    with Unix.Unix_error(e,_,_) -> raise (Unix.Unix_error (e,"close",""))

external unix_unistd_access_ptr : unit -> nativeint = "unix_unistd_access_ptr"

let access =
  let c = local ~check_errno:true (unix_unistd_access_ptr ())
    PosixTypes.(string @-> Access.(view ~host) @-> returning int)
  in
  fun pathname mode ->
    try ignore (c pathname mode)
    with Unix.Unix_error(e,_,_) -> raise (Unix.Unix_error (e,"access",pathname))

external unix_unistd_readlink_ptr : unit -> nativeint = "unix_unistd_readlink_ptr"

let readlink =
  let c = local ~check_errno:true (unix_unistd_readlink_ptr ())
    PosixTypes.(string @-> ptr void @-> size_t @-> returning size_t)
  in
  fun path ->
    try
      let sz = ref (Sysconf.(pagesize ~host)) in
      let buf = ref (allocate_n uint8_t ~count:!sz) in
      let len = ref Size_t.(to_int (c path (to_voidp !buf) (of_int !sz))) in
      while !len = !sz do
        sz  := !sz * 2;
        buf := allocate_n uint8_t ~count:!sz;
        len := Size_t.(to_int (c path (to_voidp !buf) (of_int !sz)))
      done;
      CArray.(set (from_ptr !buf (!len+1)) !len (UInt8.of_int 0));
      coerce (ptr uint8_t) string !buf
    with Unix.Unix_error(e,_,_) -> raise (Unix.Unix_error (e,"readlink",path))

external unix_unistd_symlink_ptr : unit -> nativeint = "unix_unistd_symlink_ptr"

let symlink =
  let c = local ~check_errno:true (unix_unistd_symlink_ptr ())
    PosixTypes.(string @-> string @-> returning int)
  in
  fun source dest ->
    try ignore (c source dest)
    with Unix.Unix_error(e,_,_) -> raise (Unix.Unix_error (e,"symlink",dest))

external unix_unistd_truncate_ptr : unit -> nativeint = "unix_unistd_truncate_ptr"

let truncate =
  let c = local ~check_errno:true (unix_unistd_truncate_ptr ())
    PosixTypes.(string @-> off_t @-> returning int)
  in
  fun path length ->
    try ignore (c path (to_off_t length))
    with Unix.Unix_error(e,_,_) -> raise (Unix.Unix_error (e,"truncate",path))

external unix_unistd_ftruncate_ptr : unit -> nativeint = "unix_unistd_ftruncate_ptr"

let ftruncate =
  let c = local ~check_errno:true (unix_unistd_ftruncate_ptr ())
    PosixTypes.(fd @-> off_t @-> returning int)
  in
  fun fd length ->
    try ignore (c fd (to_off_t length))
    with Unix.Unix_error(e,_,_) -> raise (Unix.Unix_error (e,"ftruncate",""))

external unix_unistd_chown_ptr : unit -> nativeint = "unix_unistd_chown_ptr"

let to_uid_t = Uid.of_int
let to_gid_t = Gid.of_int

let chown =
  let c = local ~check_errno:true (unix_unistd_chown_ptr ())
    PosixTypes.(string @-> uid_t @-> gid_t @-> returning int)
  in
  fun path owner group ->
    try ignore (c path (to_uid_t owner) (to_gid_t group))
    with Unix.Unix_error(e,_,_) -> raise (Unix.Unix_error (e,"chown",path))

external unix_unistd_fchown_ptr : unit -> nativeint = "unix_unistd_fchown_ptr"

let fchown =
  let c = local ~check_errno:true (unix_unistd_fchown_ptr ())
    PosixTypes.(fd @-> uid_t @-> gid_t @-> returning int)
  in
  fun fd owner group ->
    try ignore (c fd (to_uid_t owner) (to_gid_t group))
    with Unix.Unix_error(e,_,_) -> raise (Unix.Unix_error (e,"fchown",""))

(* Process functions *)

external unix_unistd_seteuid_ptr : unit -> nativeint = "unix_unistd_seteuid_ptr"

let seteuid =
  let c = local ~check_errno:true (unix_unistd_seteuid_ptr ())
    PosixTypes.(uid_t @-> returning int)
  in
  fun uid ->
    try ignore (c (to_uid_t uid))
    with Unix.Unix_error(e,_,_) -> raise (Unix.Unix_error (e,"seteuid",""))

external unix_unistd_setegid_ptr : unit -> nativeint = "unix_unistd_setegid_ptr"

let setegid =
  let c = local ~check_errno:true (unix_unistd_setegid_ptr ())
    PosixTypes.(gid_t @-> returning int)
  in
  fun gid ->
    try ignore (c (to_gid_t gid))
    with Unix.Unix_error(e,_,_) -> raise (Unix.Unix_error (e,"setegid",""))
