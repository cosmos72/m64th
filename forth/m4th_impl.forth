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


\ find an optimized sequence to replace a single token being compiled.
: (optimize-1token) \ ( tok-addr -- counted-tokens | 0 )
   (ip>data) 1token - bounds                  \ ( tok-addr data-end data  )
   rot token@ -rot                            \ ( tok      data-end data  )
   do                                         \ ( tok                     ) (R: data-end data )
      dup i token@ =                          \ ( tok t|f                 ) (R: data-end data )
      if                                      \ ( tok                     ) (R: data-end data )
         drop i token+ unloop                 \ ( counted-tokens          )
         exit                                 \ ( counted-tokens          )
      then                                    \ ( tok                     ) (R: data-end data )
      4 tokens                                \ ( tok 4*SZt               ) (R: data-end data )
   +loop                                      \ ( tok                     )
   drop 0      \ no optimization found        \ ( 0                       )
;


\ optimize single tokens being compiled. return t if something was optimized
: (optimize-1) \ ( src dst src-end -- src' dst' t|f )
   false 2>r                                  \ ( src dst      ) (R: src-end f   )
   begin                                      \ ( src dst      ) (R: src-end t|f )
      over r2nd@ <                            \ ( src dst t|f  ) (R: src-end t|f )
   while                                      \ ( src dst      ) (R: src-end t|f )
      false (optimize-1token)                 \ ( src' dst' n  ) (R: src-end t|f )
      0<                                      \ ( src dst t|f  ) (R: src-end t|f )
      dup r@ or r!                            \ ( src dst t|f  ) (R: src-end t|f')
      1token and                              \ ( src dst SZt|0) (R: src-end t|f )
      cmove/count                             \ ( src' dst'    ) (R: src-end t|f )
   repeat                                     \ ( src' dst'    ) (R: src-end t|f )
   r>drop r>                                  \ ( optimized code is at dst...dst')
;


\ optimize token pairs being compiled
: (optimize-2token)    \ ( src-addr dst-addr -- src-addr' dst-addr' t|f )
   (ip>data>addr) >r                          \ ( src dst               ) (R: hashmap )
   over token@ hop token[1]                   \ ( src dst tok0 tok1     ) (R: hashmap )
   8 tokens lshift or                         \ ( src dst tok0|tok1<<16 ) (R: hashmap )
   r> swap                                    \ ( src dst hashmap key  )
   hashmap-find/int                           \ ( src dst key' val' t|f )
   0= if                                      \ ( src dst key' val'     )
      2drop 1token                            \ ( src dst SZt           )
      cmove/count false exit                  \ ( src' dst' false       )
   then                                       \ ( src dst key val       )
   nip dup 8 tokens rshift swap >token 0      \ ( src dst val>>16 len 0 )
   ?do                                        \ ( src dst toks          ) (R: len 0    )
      tuck >token                             \ ( src toks dst toki     ) (R: len i    )
      over token!                             \ ( src toks dst          ) (R: len i    )
      token+                                  \ ( src toks dst'         ) (R: len i    )
      swap 8 tokens rshift                    \ ( src dst toks>>16      ) (R: len i    )
   loop                                       \ ( src dst 0             )
   drop swap token+ token+ swap true          \ ( src' dst true         )
;


disassemble-upto (optimize-2token)
