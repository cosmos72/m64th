\
\ Copyright (C) 2020 Massimiliano Ghilardi
\
\ This file is part of m4th.
\
\ m4th is free software: you can redistribute it and/or modify
\ it under the terms of the GNU Lesser General Public License
\ as published by the Free Software Foundation, either version 3
\ of the License, or (at your option) any later version.
\
\ m4th is distributed in the hope that it will be useful,
\ but WITHOUT ANY WARRANTY; without even the implied warranty of
\ MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
\ GNU Lesser General Public License for more details.
\
\ You should have received a copy of the GNU Lesser General Public License
\ along with m4th.  If not, see <https://www.gnu.org/licenses/>.

also m4th-core \ parse-nt

\ convert counted string to name, or 0 if not found
: find   ( c-addr -- c-addr 0 | xt 1 | xt -1 )
   dup count                               ( c-addr c-addr' u      )
   ['] parse-nt catch nip                  ( c-addr nt -1|1 err    )
   if                                      ( c-addr x y            )
     2drop zero                            ( c-addr 0              )
   else                                    ( c-addr nt -1|1        )
     rot drop                              ( nt -1|1               )
     swap name>xt swap                     ( xt -1|1               )
   then                                    ( c-addr 0 | xt -1 | xt 1 )
;


disassemble-upto find
