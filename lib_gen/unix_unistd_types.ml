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

module C(F: Cstubs.Types.TYPE) = struct

  module Access = struct
    let t = F.int

    let r_ok = F.constant "R_OK" t
    let w_ok = F.constant "W_OK" t
    let x_ok = F.constant "X_OK" t
    let f_ok = F.constant "F_OK" t
  end

  module Seek = struct
    let t = F.int

    let seek_set  = F.constant "SEEK_SET"  t
    let seek_cur  = F.constant "SEEK_CUR"  t
    let seek_end  = F.constant "SEEK_END"  t
    let seek_data = F.constant "SEEK_DATA" t
    let seek_hole = F.constant "SEEK_HOLE" t
  end

  module Sysconf = struct
    let t = F.int

    let _sc_pagesize = F.constant "_SC_PAGESIZE" t
  end
end
