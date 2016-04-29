(*
 * Copyright (c) 2016 Jeremy Yallop <yallop@gmail.com>
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

let header = "                                                       \n\
#define _DEFAULT_SOURCE                                              \n\
#define _BSD_SOURCE                                                  \n\
#define _XOPEN_SOURCE 600                                            \n\
#define _GNU_SOURCE // includes the previous feature macros on Linux \n\
                                                                     \n\
#include <sys/types.h>                                               \n\
#include <unistd.h>                                                  \n\
                                                                     \n\
#ifndef SEEK_DATA                                                    \n\
#define SEEK_DATA (-1)                                               \n\
#endif                                                               \n\
#ifndef SEEK_HOLE                                                    \n\
#define SEEK_HOLE (-1)                                               \n\
#endif                                                               \n\
"

let () =
  let type_oc = open_out "lib_gen/unix_unistd_types_detect.c" in
  let fmt = Format.formatter_of_out_channel type_oc in
  Format.fprintf fmt "%s@." header;
  Cstubs.Types.write_c fmt (module Unix_unistd_types.C);
  close_out type_oc;
