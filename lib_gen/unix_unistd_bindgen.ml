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

let headers = "\
#define _DEFAULT_SOURCE\n\
#define _BSD_SOURCE\n\
#define _XOPEN_SOURCE 600\n\
#define _GNU_SOURCE // includes the previous feature macros on Linux\n\
\n\
#include <stdint.h>\n\
#include <sys/types.h>\n\
#include <unistd.h>\n\
"

let () = Ctypes_stub_generator.main
    [ { Ctypes_stub_generator.name = "unix";
        errno = Cstubs.return_errno;
        concurrency = Cstubs.unlocked;
        headers;
        bindings = (module Unix_unistd_bindings.C) };
      
      { Ctypes_stub_generator.name = "lwt";
        errno = Cstubs.return_errno;
        concurrency = Cstubs.lwt_jobs;
        headers;
        bindings = (module Unix_unistd_bindings.C) } ]
