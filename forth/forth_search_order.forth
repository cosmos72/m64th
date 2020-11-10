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

also m4th-core \ searchorder*

\ set compilation wordlist to first wordlist in search order
: definitions \ ( -- )
   0 searchorder-pick                      \ ( wid                 )
  set-current ;                            \ (                     )


\ get all wordlists in search order
: get-order \ (S: widn .. wid1 -- idem ) ( -- widn ... wid1 n )
   0 searchorder-depth 1-                  \ ( 0 n-1               )
   ?do                                     \ (                     ) (R: 0 i )
      i searchorder-pick                   \ ( widi+1              ) (R: 0 i )
   -1 +loop                                \ ( widn .. wid1        )
   searchorder-depth ;


\ set search order to the single wordlist forth-root
: only \ (S: * -- forth-root )
   searchorder-clear also forth-root ;


\ remove first wordlist in search order
: previous \ (S: wid -- )
   searchorder-drop ;


\ set the search order to ( widn ... wid1 )
: set-order \ ( widn ... wid1 n -- ) (S: * -- widn ... wid1 )
   dup>r                                   \ ( * n                 ) (R: n     )
   searchorder-clear                       \ ( * n                 ) (R: n 0 i )
   0 swap ?do                              \ ( *                   ) (R: n 0 i )
      i pick                               \ ( * widi+1            ) (R: n 0 i )
      also searchorder[0]!                 \ ( *                   ) (R: n 0 i )
   -1 +loop                                \ ( *                   ) (R: n     )
   r>                                      \ ( * n                 )
   n>drop ;                                \ (                     )


disassemble definitions
disassemble get-order
disassemble only
disassemble previous
disassemble set-order
