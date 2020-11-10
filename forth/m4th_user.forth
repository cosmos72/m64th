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

also m4th-core \ wordlist-last-name string>name ex-message!
also m4th-user definitions

\ get all names in wordlist up to given name.
\ newer names are placed toward top of the stack
: wordlist-upto-name \ ( wid nt1 -- 0 | ntu ... nt2 nt1 u )
   >r wordlist-last-name 0 swap            \ ( 0 nt-last           ) (R: nt1 )
   begin                                   \ ( * i nti             ) (R: nt1 )
      dup while                            \ ( * i nti             ) (R: nt1 )
      swap 1+                              \ ( * nti i'            ) (R: nt1 )
      over dup r@ <> while                 \ ( * nti i nti         ) (R: nt1 )
      name>prev                            \ ( * nti i nti'        ) (R: nt1 )
   repeat then                             \ ( ntu ... nt1 u x     ) (R: nt1 )
   drop r> drop ;                          \ ( ntu ... nt1 u       )


\ show disassembly of N names
: disassemble-names \ ( ntu ... nt2 nt1 u -- )
   0 ?do                                   \ ( ntu ... nti         ) (R: u i )
     disassemble-name                      \ ( ntu ... nti+1       ) (R: u i )
   loop ;                                  \ (                     )


\ read name, find corresponding nt and wid containing it,
\ then show disassembly of all names in wordlist wid up to nt
: disassemble-upto \ ( -- )
   parse-nt drop                           \ ( nt wid                     )
   swap                                    \ ( wid nt                     )
   wordlist-upto-name                      \ ( ntu ... nt2 nt1 u          )
   disassemble-names ;                     \ (                            )


disassemble-upto wordlist-upto-name
