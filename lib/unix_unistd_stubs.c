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

#ifndef _SC_PAGESIZE
#error "unix_unistd_stubs.c: _SC_PAGESIZE macro not found"
#endif

CAMLprim value unix_unistd_r_ok() { return Val_int(R_OK); }
CAMLprim value unix_unistd_w_ok() { return Val_int(W_OK); }
CAMLprim value unix_unistd_x_ok() { return Val_int(X_OK); }
CAMLprim value unix_unistd_f_ok() { return Val_int(F_OK); }

CAMLprim value unix_unistd_pagesize() { return sysconf(_SC_PAGESIZE); }

ssize_t unix_unistd_read(int fd, void *buf, size_t count) {
  ssize_t retval;
  caml_release_runtime_system();
  retval = read(fd, buf, count);
  caml_acquire_runtime_system();
  return retval;
}

value unix_unistd_read_ptr(value _) {
  return caml_copy_int64((intptr_t)(void *)unix_unistd_read);
}

int unix_unistd_close(int fd) {
  int retval;
  caml_release_runtime_system();
  retval = close(fd);
  caml_acquire_runtime_system();
  return retval;
}

value unix_unistd_close_ptr(value _) {
  return caml_copy_int64((intptr_t)(void *)unix_unistd_close);
}
