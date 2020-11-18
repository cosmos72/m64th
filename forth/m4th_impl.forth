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
   (ip>data) 1token - bounds                   \ ( tok-addr data-end data  )
   rot token@ -rot                             \ ( tok      data-end data  )
   do                                          \ ( tok                     ) (R: data-end data )
      dup i token@ =                           \ ( tok t|f                 ) (R: data-end data )
      if                                       \ ( tok                     ) (R: data-end data )
         drop i token+ unloop                  \ ( counted-tokens          )
         exit                                  \ ( counted-tokens          )
      then                                     \ ( tok                     ) (R: data-end data )
      4 tokens                                 \ ( tok 4*SZt               ) (R: data-end data )
   +loop                                       \ ( tok                     )
   drop 0      \ no optimization found         \ ( 0                       )
;


\ find an optimized sequence to replace two tokens being compiled.
: (optimize-2token)    \ ( tok-addr -- counted-tokens | 0 )
   (ip>data>addr) swap                         \ ( hashmap tok-addr        )
   dup token@ swap token[1]                    \ ( hashmap tok0 tok1       )
   8 tokens lshift or                          \ ( hashmap tok0|tok1<<16   ) \ key = tok0|tok1<<16
   hashmap-find/int                            \ ( key' &val|0             )
   nip                                         \ ( &val|0                  )
;

\ find an optimized sequence to replace three tokens being compiled.
: (optimize-3token)    \ ( tok-addr -- counted-tokens | 0 )
   (ip>data>addr) swap dup>r                   \ ( hashmap tok-addr               ) (R: tok-addr )
   token@ r@ token[1]                          \ ( hashmap tok0 tok1              ) (R: tok-addr )
   8 tokens lshift or                          \ ( hashmap tok0|tok1<<16          ) (R: tok-addr )
   r> token[2]                                 \ ( hashmap tok0|tok1<<16 tok2     )
   16 tokens lshift or                         \ ( hashmap tok0|tok1<<16|tok2<<32 )
   hashmap-find/cell                           \ ( key' &val|0                    )
   nip                                         \ ( &val|0                         )
;

\ find an optimized sequence to replace N tokens being compiled.
\ return address of optimized sequence and u' = number of consumed tokens, or 0 0
: (optimize-tokens)    \ ( tok-addr u -- counted-tokens u' | 0 0 )
   dup if                                      \ ( tok-addr u                     )
      over (optimize-1token)                   \ ( tok-addr u counted-tokens|0    )
      dup if                                   \ ( tok-addr u counted-tokens      )
         nip nip 1 exit                        \ ( counted-tokens 1               )
      then                                     \ ( tok-addr u 0                   )
      drop                                     \ ( tok-addr u                     )
   then                                        \ ( tok-addr u                     )
   dup 2 u>=                                   \ ( tok-addr u t|f                 )
   if                                          \ ( tok-addr u                     )
      over (optimize-2token)                   \ ( tok-addr u counted-tokens|0    )
      dup if                                   \ ( tok-addr u counted-tokens      )
         nip nip 2 exit                        \ ( counted-tokens 2               )
      then                                     \ ( tok-addr u 0                   )
      drop                                     \ ( tok-addr u                     )
   then                                        \ ( tok-addr u                     )
   dup 3 u>=                                   \ ( tok-addr u t|f                 )
   if                                          \ ( tok-addr u                     )
      over (optimize-3token)                   \ ( tok-addr u counted-tokens|0    )
      dup if                                   \ ( tok-addr u counted-tokens      )
         nip nip 3 exit                        \ ( counted-tokens 3               )
      then                                     \ ( tok-addr u 0                   )
      drop                                     \ ( tok-addr u                     )
   then                                        \ ( tok-addr u                     )
   2drop 0 0                                   \ ( 0 0                            )
;

\ copy and optimize at least one token from src to HERE. updates HERE src and u
: (optimize-tokens,)  \ ( src u -- src' u' )
   dup 0=                                      \ ( src u t|f                )
   if                                          \ ( src u                    )
      exit                                     \ ( src u                    )
   then                                        \ ( src u                    )
   2dup 2>r                                    \ ( src u                    ) (R: src u )
   (optimize-tokens)                           \ ( countedtokens|0 iu|0     ) (R: src u )
   dup if                                      \ ( countedtokens iu         ) (R: src u )
      swap countedtokens,                      \ ( iu                       ) (R: src u )
   else                                        \ ( 0 0                      ) (R: src u )
      2drop                                    \ (                          ) (R: src u )
      r2nd@ token@ token,                      \ (                          ) (R: src u )
      1                                        \ ( 1                        ) (R: src u )
   then                                        \ ( iu                       ) (R: src u )
   dup tokens r2nd@ +                          \ ( iu src'                  ) (R: src u )
   swap r@ -                                   \ ( src' u'                  ) (R: src u )
   2r> 2drop                                   \ ( src' u'                  )
;




disassemble-upto (optimize-1token)
