ocaml-unix-unistd
================

[ocaml-unix-unistd](https://github.com/dsheets/ocaml-unix-unistd) provides
host-dependent unistd.h access.

**WARNING**: not portable due to *read*, *close*, *access*, *symlink*,
*readlink*, *truncate*, and *ftruncate* wrappers that assume 64-bit
instruction pointers.
