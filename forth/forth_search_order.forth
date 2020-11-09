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

also m4th-core \ words searchorder*

\ set compilation wordlist to first wordlist in search order
: definitions \ ( -- )
   0 searchorder-pick                      \ ( wid                )
  set-current ;                            \ (                    )


\ get all wordlists in search order
: get-order \ (S: wid_u-1 .. wid_0 -- idem ) ( -- wid_u-1 ... wid_0 u )
   0 searchorder-depth 1-                  \ ( 0 u-1               )
   ?do                                     \ (                     ) (R: 0 i )
      i searchorder-pick                   \ ( wid_i               ) (R: 0 i )
   -1 +loop                                \ ( wid_u-1 .. wid_0    )
   searchorder-depth ;


\ remove first wordlist in search order
: previous \ (S: wid -- )
   searchorder-drop ;


disassemble definitions
disassemble get-order
disassemble previous
