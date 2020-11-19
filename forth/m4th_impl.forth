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
   2>r r@ if                                   \ (                     ) (R: tok-addr u )
      r2nd@ (optimize-1token)                  \ ( counted-tokens|0    ) (R: tok-addr u )
      ?dup if                                  \ ( counted-tokens      ) (R: tok-addr u )
         2r> 2drop 1 exit                      \ ( counted-tokens 1    )
      then                                     \ (                     ) (R: tok-addr u )
   then                                        \ (                     ) (R: tok-addr u )
   r@ 2 u>=                                    \ ( t|f                 ) (R: tok-addr u )
   if                                          \ (                     ) (R: tok-addr u )
      r2nd@ (optimize-2token)                  \ ( counted-tokens|0    ) (R: tok-addr u )
      ?dup if                                  \ ( counted-tokens      ) (R: tok-addr u )
         2r> 2drop 2 exit                      \ ( counted-tokens 2    )
      then                                     \ (                     ) (R: tok-addr u )
   then                                        \ (                     ) (R: tok-addr u )
   r@ 3 u>=                                    \ ( t|f                 ) (R: tok-addr u )
   if                                          \ (                     ) (R: tok-addr u )
      r2nd@ (optimize-3token)                  \ ( counted-tokens|0    ) (R: tok-addr u )
      ?dup if                                  \ ( counted-tokens      ) (R: tok-addr u )
         2r> 2drop 3 exit                      \ ( counted-tokens 3    ) (R: tok-addr u )
      then                                     \ (                     ) (R: tok-addr u )
   then                                        \ (                     ) (R: tok-addr u )
   2r> 2drop 0 0                               \ ( 0 0                 )
;


\ copy and optimize at least one token from src to HERE. updates HERE.
\ return number of consumed tokens, and true if an optimized sequence was found, else false.
: (optimize-tokens,)  \ ( src u -- u' t|f )
   dup 0=                                      \ ( src u t|f                )
   if                                          \ ( src 0                    )
      nip false exit                           \ ( 0 false                  )
   then                                        \ ( src u                    )
   trail                                       \ ( src src u                )
   (optimize-tokens)                           \ ( src countedtokens|0 iu|0 )
   dup if                                      \ ( src countedtokens iu     )
      swap countedtokens,                      \ ( src iu                   )
      nip true                                 \ ( iu true                  )
   else                                        \ ( src 0 0                  )
      1+ flip                                  \ ( 1 false src              )
      token@ token,                            \ ( 1 false                  )
   then                                        \ ( iu t|f                   )
;


\ copy and optimize exactly u tokens from src to HERE. updates HERE.
\ return true if something was optimized, else false
: (optimize,)   \ ( src u -- t|f )
  false >r                                     \ (               ) (R: false )
  begin                                        \ ( src u         ) (R: t|f   )
     dup                                       \ ( src u u       ) (R: t|f   )
  while                                        \ ( src u         ) (R: t|f   )
     (optimize-tokens,)                        \ ( src' u' t|f'  ) (R: t|f   )
     r@ or r!                                  \ ( src' u'       ) (R: t|f'  )
  repeat                                       \ ( src' u'       ) (R: t|f   )
  2drop r>                                     \ ( t|f           )
;


disassemble-upto (optimize-1token)
