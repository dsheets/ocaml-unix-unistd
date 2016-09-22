(*
 * Copyright (c) 2016 Jeremy Yallop
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

open Ctypes
open Posix_types

let fd = Unix_representations
         .(view int ~read:file_descr_of_int ~write:int_of_file_descr)

module C(F: Cstubs.FOREIGN) = struct
  open F

  let lseek = foreign "lseek"
    (fd @-> off_t @-> int @-> returning off_t)

  let unlink = foreign "unlink"
    (string @-> returning int)
      
  let rmdir = foreign "rmdir"
    (string @-> returning int)

  let write = foreign "write"
    (fd @-> ptr void @-> size_t @-> returning ssize_t)

  let pwrite = foreign "pwrite"
    (fd @-> ptr void @-> size_t @-> off_t @-> returning ssize_t)

  let read = foreign "read"
    (fd @-> ptr void @-> size_t @-> returning ssize_t)

  let pread = foreign "pread"
    (fd @-> ptr void @-> size_t @-> off_t @-> returning ssize_t)

  let close = foreign "close"
    (fd @-> returning int)

  let access = foreign "access"
    (string @-> int @-> returning int)

  let readlink = foreign "readlink"
    (string @-> ptr char @-> size_t @-> returning ssize_t)

  let symlink = foreign "symlink"
    (string @-> string @-> returning int)

  let truncate = foreign "truncate"
    (string @-> off_t @-> returning int)

  let ftruncate = foreign "ftruncate"
    (fd @-> off_t @-> returning int)

  let chown = foreign "chown"
    (string @-> uid_t @-> gid_t @-> returning int)

  let fchown = foreign "fchown"
    (fd @-> uid_t @-> gid_t @-> returning int)

  let seteuid = foreign "seteuid"
    (uid_t @-> returning int)

  let setegid = foreign "setegid"
    (gid_t @-> returning int)
end
