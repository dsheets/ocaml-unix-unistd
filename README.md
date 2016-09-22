ocaml-unix-unistd
=================

[ocaml-unix-unistd](https://github.com/dsheets/ocaml-unix-unistd) provides
access to the features exposed in [`unistd.h`][unistd.h] in a way that is not
tied to the implementation on the host system.

The [`Unistd`][unistd] module provides functions for translating between the
constants accessible through `unistd.h` and their values on particular
systems.

The [`Unistd_unix`][unistd_unix] module provides bindings to functions that
use the constants and types in `Unistd` along with a representation of the
host system.  The bindings support a more comprehensive range of seek commands
than the corresponding functions in the standard OCaml `Unix` module.  The
[`Unistd_unix_lwt`][unistd_unix_lwt] module exports non-blocking versions of
the functions in `Unistd_unix` based on the [Lwt][lwt] cooperative threading
library.

[unistd.h]: http://pubs.opengroup.org/onlinepubs/9699919799/basedefs/unistd.h.html
[unistd]: https://github.com/dsheets/ocaml-unix-unistd/blob/master/lib/unistd.mli
[unistd_unix]: https://github.com/dsheets/ocaml-unix-unistd/blob/master/unix/unistd_unix.mli
[unistd_unix_lwt]: https://github.com/dsheets/ocaml-unix-unistd/blob/master/lwt/unistd_unix_lwt.mli
[lwt]: http://ocsigen.org/lwt/
