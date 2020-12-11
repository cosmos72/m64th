\
\ Copyright (C) 2020 Massimiliano Ghilardi
\
\ This file is part of m64th.
\
\ m64th is free software: you can redistribute it and/or modify
\ it under the terms of the GNU Lesser General Public License
\ as published by the Free Software Foundation, either version 3
\ of the License, or (at your option) any later version.
\
\ m64th is distributed in the hope that it will be useful,
\ but WITHOUT ANY WARRANTY; without even the implied warranty of
\ MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
\ GNU Lesser General Public License for more details.
\
\ You should have received a copy of the GNU Lesser General Public License
\ along with m64th.  If not, see <https://www.gnu.org/licenses/>.

also m64th-core \ searchorder* wordlist*

\ replace first wordlist in search order with 'forth' wordlist
: forth   ( SO: wid -- forth )
   forth-wordlist                            ( wid                 )
   searchorder[0]!                           (                     )
;


\ get all wordlists in search order
: get-order   ( SO: widn .. wid1 -- idem ) ( -- widn ... wid1 n )
   searchorder-depth 0                       ( 0 n                 )
   ?do                                       (                     ) ( R: n i )
      i' i - 1-                              ( n-i-1               ) ( R: n i )
      searchorder-pick                       ( widn                ) ( R: n i )
   loop                                      ( widn .. wid1        )
   searchorder-depth                         ( widn .. wid1 n      )
;


\ type the wordlists in search order
: order
   get-order 0                               ( widn .. wid1 n 0    )
   ?do                                       ( widn .. widi        ) ( R: n i )
      space wordlist>string type             ( widn .. widi+1      ) ( R: n i )
   loop                                      (                     )
   4 spaces get-current                      ( wid                 )
   wordlist>string type                      (                     )
;


\ set the search order to exactly ( widn ... wid1 )
\ if n is -1, set implementation-defined minimum search order
: set-order   ( widn ... wid1 n -- ) ( SO: * -- widn ... wid1 )
   dup 0< if                                 ( -u                  )
      drop only exit
   then                                      ( * n                 )
   searchorder-clear                         ( * n                 )
   dup>r                                     ( * n                 ) ( R: n     )
   0 ?do                                     ( *                   ) ( R: n n i )
      i' i - 1- pick                         ( * wid(n-i-1)        ) ( R: n n i )
      also searchorder[0]!                   ( *                   ) ( R: n n i )
   loop                                      ( *                   ) ( R: n     )
   r>                                        ( * n                 )
   n>drop                                    (                     )
;


disassemble-upto forth
