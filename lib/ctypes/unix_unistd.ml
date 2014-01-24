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

module Sysconf = struct
  include Unix_unistd_common.Sysconf
end

open Ctypes
open Foreign
open Unsigned

let local ?check_errno addr typ =
  coerce (ptr void) (funptr ?check_errno typ) (ptr_of_raw_address addr)

let write =
  let c = foreign ~check_errno:true "write"
    PosixTypes.(int @-> ptr void @-> size_t @-> returning size_t) in
  fun fd buf count ->
    Size_t.to_int (c (Fd_send_recv.int_of_fd fd) buf (Size_t.of_int count))

external unix_unistd_read_ptr : unit -> int64 = "unix_unistd_read_ptr"

let read =
  let c = local ~check_errno:true (unix_unistd_read_ptr ())
    PosixTypes.(int @-> ptr void @-> size_t @-> returning size_t)
  in
  fun fd buf count ->
    Size_t.to_int (c (Fd_send_recv.int_of_fd fd) buf (Size_t.of_int count))

external unix_unistd_close_ptr : unit -> int64 = "unix_unistd_close_ptr"

let close =
  let c = local ~check_errno:true (unix_unistd_close_ptr ())
    PosixTypes.(int @-> returning int)
  in
  fun fd -> ignore (c (Fd_send_recv.int_of_fd fd))
