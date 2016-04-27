/*
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
 */

#define _DEFAULT_SOURCE
#define _BSD_SOURCE
#define _XOPEN_SOURCE 600
#define _GNU_SOURCE // includes the previous feature macros on Linux

#include <stdint.h>
#include <sys/types.h>
#include <unistd.h>
#include <caml/mlvalues.h>
#include <caml/alloc.h>
#include <caml/threads.h>

#ifndef R_OK
#error "unix_unistd_stubs.c: R_OK macro not found"
#endif
#ifndef W_OK
#error "unix_unistd_stubs.c: W_OK macro not found"
#endif
#ifndef X_OK
#error "unix_unistd_stubs.c: X_OK macro not found"
#endif
#ifndef F_OK
#error "unix_unistd_stubs.c: F_OK macro not found"
#endif

#ifndef SEEK_SET
#error "unix_unistd_stubs.c: SEEK_SET macro not found"
#endif
#ifndef SEEK_CUR
#error "unix_unistd_stubs.c: SEEK_CUR macro not found"
#endif
#ifndef SEEK_END
#error "unix_unistd_stubs.c: SEEK_END macro not found"
#endif
#ifndef SEEK_DATA
#define SEEK_DATA (-1)
#endif
#ifndef SEEK_HOLE
#define SEEK_HOLE (-1)
#endif

#ifndef _SC_PAGESIZE
#error "unix_unistd_stubs.c: _SC_PAGESIZE macro not found"
#endif

CAMLprim value unix_unistd_r_ok() { return Val_int(R_OK); }
CAMLprim value unix_unistd_w_ok() { return Val_int(W_OK); }
CAMLprim value unix_unistd_x_ok() { return Val_int(X_OK); }
CAMLprim value unix_unistd_f_ok() { return Val_int(F_OK); }

CAMLprim value unix_unistd_seek_set()  { return Val_int(SEEK_SET); }
CAMLprim value unix_unistd_seek_cur()  { return Val_int(SEEK_CUR); }
CAMLprim value unix_unistd_seek_end()  { return Val_int(SEEK_END); }
CAMLprim value unix_unistd_seek_data() { return Val_int(SEEK_DATA); }
CAMLprim value unix_unistd_seek_hole() { return Val_int(SEEK_HOLE); }

CAMLprim value unix_unistd_pagesize() { return sysconf(_SC_PAGESIZE); }

