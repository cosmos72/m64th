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

also m4th-core
also m4th-impl definitions


\ optimize token pairs being compiled
: (optimize-2token)    \ ( src-addr dst-addr -- src-addr' dst-addr' t|f )
   (ip>data>addr) >r                          \ ( src dst               ) (R: hashmap )
   over token@ hop token+ token@              \ ( src dst tok0 tok1     ) (R: hashmap )
   8 tokens lshift or                         \ ( src dst tok0|tok1<<16 ) (R: hashmap )
   r> swap                                    \ ( src dst hashmap key  )
   hashmap-find/int                           \ ( src dst key' val' t|f )
   0= if                                      \ ( src dst key' val'     )
      2drop 1token                            \ ( src dst SZt           )
      cmove/count false exit                  \ ( src' dst' false       )
   then                                       \ ( src dst key val       )
   nip dup 8 tokens rshift swap to-token 0    \ ( src dst val>>16 len 0 )
   ?do                                        \ ( src dst toks          ) (R: len 0    )
      tuck to-token                           \ ( src toks dst toki     ) (R: len i    )
      over token!                             \ ( src toks dst          ) (R: len i    )
      token+                                  \ ( src toks dst'         ) (R: len i    )
      swap 8 tokens rshift                    \ ( src dst toks>>16      ) (R: len i    )
   loop                                       \ ( src dst 0             )
   drop swap token+ token+ swap true          \ ( src' dst true         )
;


disassemble-upto (optimize-2token)
