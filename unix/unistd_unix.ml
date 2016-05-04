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
open Foreign
open Unsigned

let local addr typ =
  coerce (ptr void) (funptr typ) (ptr_of_raw_address addr)

let to_off_t = coerce int64_t PosixTypes.off_t

module Uid = UInt
let uid_t = uint
module Gid = UInt
let gid_t = uint

let fd = Unix_representations.(view int ~read:file_descr_of_int ~write:int_of_file_descr)

(* Filesystem functions *)

external unix_unistd_lseek_ptr : unit -> nativeint = "unix_unistd_lseek_ptr"

let lseek =
  let cmd =
    let write cmd = match Unistd.Seek.to_code ~host:Seek.host cmd with
      | Some code -> code
      | None -> raise Unix.(Unix_error (EINVAL,"lseek",""))
    in
    Ctypes.(view ~read:(Unistd.Seek.of_code_exn ~host:Seek.host) ~write int)
  in
  let c = local (unix_unistd_lseek_ptr ())
    PosixTypes.(fd @-> off_t @-> cmd @-> returning off_t)
  in
  fun fd offset whence ->
    let offset = to_off_t offset in
    Errno_unix.raise_on_errno ~call:"lseek" begin fun () ->
        (match coerce PosixTypes.off_t int64_t (c fd offset whence) with
          | -1L -> None
          | off -> Some off)
    end

external unix_unistd_unlink_ptr : unit -> nativeint = "unix_unistd_unlink_ptr"

let unlink =
  let c = local (unix_unistd_unlink_ptr ())
    PosixTypes.(string @-> returning int)
  in
  fun pathname ->
    Errno_unix.raise_on_errno ~call:"unlink" ~label:pathname begin fun () ->
      match c pathname with
      | -1 -> None
      | 0 | _ -> Some ()
    end

external unix_unistd_rmdir_ptr : unit -> nativeint = "unix_unistd_rmdir_ptr"

let rmdir =
  let c = local (unix_unistd_rmdir_ptr ())
    PosixTypes.(string @-> returning int)
  in
  fun pathname ->
    Errno_unix.raise_on_errno ~call:"rmdir" ~label:pathname begin fun () ->
      match c pathname with
      | -1 -> None
      | 0 | _ -> Some ()
    end

external unix_unistd_write_ptr : unit -> nativeint = "unix_unistd_write_ptr"

let write =
  let c = local (unix_unistd_write_ptr ())
    PosixTypes.(fd @-> ptr void @-> size_t @-> returning size_t)
  in
  fun fd buf count ->
    Errno_unix.raise_on_errno ~call:"write" begin fun () ->
      match Size_t.to_int (c fd buf (Size_t.of_int count)) with
      | -1 -> None
      | sz -> Some sz
    end

external unix_unistd_pwrite_ptr : unit -> nativeint = "unix_unistd_pwrite_ptr"

let pwrite =
  let c = local (unix_unistd_pwrite_ptr ())
    PosixTypes.(fd @-> ptr void @-> size_t @-> off_t @-> returning size_t)
  in
  fun fd buf count offset ->
    let offset = to_off_t offset in
    Errno_unix.raise_on_errno ~call:"pwrite" begin fun () ->
      match Size_t.to_int (c fd buf (Size_t.of_int count) offset) with
      | -1 -> None
      | sz -> Some sz
    end

external unix_unistd_read_ptr : unit -> nativeint = "unix_unistd_read_ptr"

let read =
  let c = local (unix_unistd_read_ptr ())
    PosixTypes.(fd @-> ptr void @-> size_t @-> returning size_t)
  in
  fun fd buf count ->
    Errno_unix.raise_on_errno ~call:"read" begin fun () ->
      match Size_t.to_int (c fd buf (Size_t.of_int count)) with
      | -1 -> None
      | sz -> Some sz
    end

external unix_unistd_pread_ptr : unit -> nativeint = "unix_unistd_pread_ptr"

let pread =
  let c = local (unix_unistd_pread_ptr ())
    PosixTypes.(fd @-> ptr void @-> size_t @-> off_t @-> returning size_t)
  in
  fun fd buf count offset ->
    let offset = to_off_t offset in
    Errno_unix.raise_on_errno ~call:"pread" begin fun () ->
      match Size_t.to_int (c fd buf (Size_t.of_int count) offset) with
      | -1 -> None
      | sz -> Some sz
    end

external unix_unistd_close_ptr : unit -> nativeint = "unix_unistd_close_ptr"

let close =
  let c = local (unix_unistd_close_ptr ())
    PosixTypes.(fd @-> returning int)
  in
  fun fd ->
    Errno_unix.raise_on_errno ~call:"close" begin fun () ->
      match c fd with
      | -1 -> None
      | 0 | _ -> Some ()
    end

external unix_unistd_access_ptr : unit -> nativeint = "unix_unistd_access_ptr"

let access =
  let c = local (unix_unistd_access_ptr ())
    PosixTypes.(string @-> Access.(view ~host) @-> returning int)
  in
  fun pathname mode ->
    Errno_unix.raise_on_errno ~call:"access" ~label:pathname begin fun () ->
      match c pathname mode with
      | -1 -> None
      | 0 | _ -> Some ()
    end

external unix_unistd_readlink_ptr : unit -> nativeint = "unix_unistd_readlink_ptr"

let readlink =
  let c = local (unix_unistd_readlink_ptr ())
    PosixTypes.(string @-> ptr void @-> size_t @-> returning size_t)
  in
  let c' path buf sz =
    Errno_unix.raise_on_errno ~call:"readlink" ~label:path begin fun () ->
      match Size_t.to_int (c path buf sz) with
      | -1 -> None
      | sz -> Some sz
    end
  in
  fun path ->
    try
      let sz = ref (Unistd.Sysconf.pagesize ~host:Sysconf.host) in
      let buf = ref (allocate_n uint8_t ~count:!sz) in
      let len = ref (c' path (to_voidp !buf) (Size_t.of_int !sz)) in
      while !len = !sz do
        sz  := !sz * 2;
        buf := allocate_n uint8_t ~count:!sz;
        len := c' path (to_voidp !buf) (Size_t.of_int !sz)
      done;
      CArray.(set (from_ptr !buf (!len+1)) !len (UInt8.of_int 0));
      coerce (ptr uint8_t) string !buf
    with Unix.Unix_error(e,_,_) -> raise (Unix.Unix_error (e,"readlink",path))

external unix_unistd_symlink_ptr : unit -> nativeint = "unix_unistd_symlink_ptr"

let symlink =
  let c = local (unix_unistd_symlink_ptr ())
    PosixTypes.(string @-> string @-> returning int)
  in
  fun source dest ->
    Errno_unix.raise_on_errno ~call:"symlink" ~label:dest begin fun () ->
      match c source dest with
      | -1 -> None
      | 0 | _ -> Some ()
    end

external unix_unistd_truncate_ptr : unit -> nativeint = "unix_unistd_truncate_ptr"

let truncate =
  let c = local (unix_unistd_truncate_ptr ())
    PosixTypes.(string @-> off_t @-> returning int)
  in
  fun path length ->
    Errno_unix.raise_on_errno ~call:"truncate" ~label:path begin fun () ->
      match c path (to_off_t length) with
      | -1 -> None
      | 0 | _ -> Some ()
    end

external unix_unistd_ftruncate_ptr : unit -> nativeint = "unix_unistd_ftruncate_ptr"

let ftruncate =
  let c = local (unix_unistd_ftruncate_ptr ())
    PosixTypes.(fd @-> off_t @-> returning int)
  in
  fun fd length ->
    Errno_unix.raise_on_errno ~call:"ftruncate" begin fun () ->
      match c fd (to_off_t length) with
      | -1 -> None
      | 0 | _ -> Some ()
    end

external unix_unistd_chown_ptr : unit -> nativeint = "unix_unistd_chown_ptr"

let to_uid_t = Uid.of_int
let to_gid_t = Gid.of_int

let chown =
  let c = local (unix_unistd_chown_ptr ())
    PosixTypes.(string @-> uid_t @-> gid_t @-> returning int)
  in
  fun path owner group ->
    Errno_unix.raise_on_errno ~call:"chown" ~label:path begin fun () ->
      match c path (to_uid_t owner) (to_gid_t group) with
      | -1 -> None
      | 0 | _ -> Some ()
    end

external unix_unistd_fchown_ptr : unit -> nativeint = "unix_unistd_fchown_ptr"

let fchown =
  let c = local (unix_unistd_fchown_ptr ())
    PosixTypes.(fd @-> uid_t @-> gid_t @-> returning int)
  in
  fun fd owner group ->
    Errno_unix.raise_on_errno ~call:"fchown" begin fun () ->
      match c fd (to_uid_t owner) (to_gid_t group) with
      | -1 -> None
      | 0 | _ -> Some ()
    end

(* Process functions *)

external unix_unistd_seteuid_ptr : unit -> nativeint = "unix_unistd_seteuid_ptr"

let seteuid =
  let c = local (unix_unistd_seteuid_ptr ())
    PosixTypes.(uid_t @-> returning int)
  in
  fun uid ->
    Errno_unix.raise_on_errno ~call:"seteuid" begin fun () ->
      match c (to_uid_t uid) with
      | -1 -> None
      | 0 | _ -> Some ()
    end

external unix_unistd_setegid_ptr : unit -> nativeint = "unix_unistd_setegid_ptr"

let setegid =
  let c = local (unix_unistd_setegid_ptr ())
    PosixTypes.(gid_t @-> returning int)
  in
  fun gid ->
    Errno_unix.raise_on_errno ~call:"setegid" begin fun () ->
      match c (to_gid_t gid) with
      | -1 -> None
      | 0 | _ -> Some ()
    end
