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
   set-current ;                           \ (                     )


\ get all wordlists in search order
: get-order \ (S: widn .. wid1 -- idem ) ( -- widn ... wid1 n )
   searchorder-depth 0                     \ ( 0 n                 )
   ?do                                     \ (                     ) (R: n i )
      i' i - 1-                            \ ( n-i-1               ) (R: n i )
      searchorder-pick                     \ ( widn                ) (R: n i )
   loop                                    \ ( widn .. wid1        )
   searchorder-depth ;                     \ ( widn .. wid1 n      )


\ set search order to the single wordlist forth-root
: only \ (S: * -- forth-root )
   searchorder-clear also forth-root ;


\ remove first wordlist in search order
: previous \ (S: wid -- )
   searchorder-drop ;


\ search for name in specified wordlist. return XT plus immediate flag, or zero
: search-wordlist \ ( c-addr u wid -- 0 | xt 1 | xt -1 )
   wordlist-find                           \ ( nt|0 -1|0|1         )
   dup if                                  \ ( nt   -1|1           )
      swap name>xt swap                    \ ( xt   -1|1           )
   else                                    \ ( 0    0              )
      nip                                  \ ( 0                   )
   then ;                                  \ ( 0 | xt 1 | xt -1    )


disassemble-upto definitions

\ set the search order to exactly ( widn ... wid1 )
\ if n is -1, set implementation-defined minimum search order
: set-order \ ( widn ... wid1 n -- ) (S: * -- widn ... wid1 )
   dup 0< if                               \ ( -1                 )
      only
      drop exit
   then                                    \ ( * n                 )
   searchorder-clear                       \ ( * n                 )
   dup>r                                   \ ( * n                 ) (R: n     )
   0 swap ?do                              \ ( *                   ) (R: n 0 i )
      i pick                               \ ( * widi+1            ) (R: n 0 i )
      also searchorder[0]!                 \ ( *                   ) (R: n 0 i )
   -1 +loop                                \ ( *                   ) (R: n     )
   r>                                      \ ( * n                 )
   n>drop ;                                \ (                     )

\ set-order is included in m4wordlist_forth_root : do not disassemble it here