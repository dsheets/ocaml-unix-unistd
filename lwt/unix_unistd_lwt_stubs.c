#define _DEFAULT_SOURCE
#define _BSD_SOURCE
#define _XOPEN_SOURCE 600
#define _GNU_SOURCE // includes the previous feature macros on Linux
#include <sys/types.h>
#include <unistd.h>

#include <limits.h>
#include <errno.h>

#include <caml/mlvalues.h>
#include <caml/bigarray.h>

#include "ctypes_raw_pointer.h"

#include "lwt_unix.h"

struct job_pread_c_memory {
  struct lwt_unix_job job;
  /* The file descriptor. */
  int fd;
  /* The destination buffer. */
  void *buffer;
  /* The amount of data to read. */
  size_t count;
  /* The file offset. */
  off_t offset;
  /* The result of the pread syscall. */
  ssize_t result;
  /* The value of errno. */
  int error_code;
};

static
void worker_pread_c_memory(struct job_pread_c_memory *job)
{
  job->result = pread(job->fd, job->buffer, job->count, job->offset);
  job->error_code = errno;
}

static
value result_pread_c_memory(struct job_pread_c_memory *job)
{
  long result = job->result;
  LWT_UNIX_CHECK_JOB(job, result < 0, "pread");
  lwt_unix_free_job(&job->job);
  return Val_long(result);
}

/* lwt_pread_c_memory_job:
 *   file_descr -> _ Ctypes.ptr -> len:int -> file_ofs:int64 ->
 *   int Lwt_unix.job
 */
CAMLprim
value unix_unistd_lwt_pread_c_memory_job(value val_fd,
                                         value val_buf,
                                         value val_len,
                                         value val_file_ofs)
{
  LWT_UNIX_INIT_JOB(job, pread_c_memory, 0);
  job->fd = Int_val(val_fd);
  job->buffer = CTYPES_ADDR_OF_FATPTR(val_buf);
  job->count = Long_val(val_len);
  job->offset = Int64_val(val_file_ofs);
  job->result = -1;
  job->error_code = INT_MAX;
  return lwt_unix_alloc_job(&(job->job));
}



struct job_pwrite_c_memory {
  struct lwt_unix_job job;
  /* The file descriptor. */
  int fd;
  /* The destination buffer. */
  void *buffer;
  /* The amount of data to write. */
  size_t count;
  /* The file offset. */
  off_t offset;
  /* The result of the pwrite syscall. */
  ssize_t result;
  /* The value of errno. */
  int error_code;
};

static
void worker_pwrite_c_memory(struct job_pwrite_c_memory *job)
{
  job->result = pwrite(job->fd, job->buffer, job->count, job->offset);
  job->error_code = errno;
}

static
value result_pwrite_c_memory(struct job_pwrite_c_memory *job)
{
  long result = job->result;
  LWT_UNIX_CHECK_JOB(job, result < 0, "pwrite");
  lwt_unix_free_job(&job->job);
  return Val_long(result);
}

/* lwt_pwrite_c_memory_job:
 *   file_descr -> _ Ctypes.ptr -> len:int -> file_ofs:int64 ->
 *   int Lwt_unix.job
 */
CAMLprim
value unix_unistd_lwt_pwrite_c_memory_job(value val_fd,
                                          value val_buf,
                                          value val_len,
                                          value val_file_ofs)
{
  LWT_UNIX_INIT_JOB(job, pwrite_c_memory, 0);
  job->fd = Int_val(val_fd);
  job->buffer = CTYPES_ADDR_OF_FATPTR(val_buf);
  job->count = Long_val(val_len);
  job->offset = Int64_val(val_file_ofs);
  job->result = -1;
  job->error_code = INT_MAX;
  return lwt_unix_alloc_job(&(job->job));
}
