#include <unistd.h>
#include <caml/mlvalues.h>

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

#ifndef _SC_PAGESIZE
#error "unix_unistd_stubs.c: _SC_PAGESIZE macro not found"
#endif

CAMLprim value unix_unistd_r_ok() { return Val_int(R_OK); }
CAMLprim value unix_unistd_w_ok() { return Val_int(W_OK); }
CAMLprim value unix_unistd_x_ok() { return Val_int(X_OK); }
CAMLprim value unix_unistd_f_ok() { return Val_int(F_OK); }

CAMLprim value unix_unistd_pagesize() { return sysconf(_SC_PAGESIZE); }

