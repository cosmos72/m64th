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
   (ip>data>addr) swap dup >r                  \ ( hashmap tok-addr               ) (R: tok-addr )
   token@ r@ token[1]                          \ ( hashmap tok0 tok1              ) (R: tok-addr )
   8 tokens lshift or                          \ ( hashmap tok0|tok1<<16          ) (R: tok-addr )
   r> token[2]                                 \ ( hashmap tok0|tok1<<16 tok2     )
   16 tokens lshift or                         \ ( hashmap tok0|tok1<<16|tok2<<32 )
   hashmap-find/cell                           \ ( key' &val|0                    )
   nip                                         \ ( &val|0                         )
;


\ find an optimized sequence to replace three tokens being compiled,
\ which may be part of control flow i.e. 'if' 'else' 'case' etc.
\ if no optimized sequence was found, return 0
: (optimize-3jump) \ ( tok-addr -- counted-tokens|0 )
   (ip>data>addr) swap dup                     \ ( &data addr addr     )
   token@ swap token[2]                        \ ( &data tok0 tok2     )
   8 tokens lshift                             \ ( &data tok0 tok2<<16 )
   or >r                                       \ ( &data               ) (R: key )
   begin                                       \ ( &data               ) (R: key )
      dup token@ dup                           \ ( &data tok0 tok0     ) (R: key )
   while                                       \ ( &data tok0          ) (R: key )
      over token[1]                            \ ( &data tok0 tok2     ) (R: key )
      8 tokens lshift or                       \ ( &data tok0|tok2<<16 ) (R: key )
      r@ <>                                    \ ( &data t|f           ) (R: key )
   while                                       \ ( &data               ) (R: key )
      4 tokens +                               \ ( &data'              ) (R: key )
   repeat                                      \ ( &data               ) (R: key )
      0 swap token+ token+                     \ ( 0 counted-tokens    ) (R: key )
   then                                        \ ( _ counted-tokens|0  ) (R: key )
   nip r> drop                                 \ ( counted-tokens|0    )
;


\ find an optimized sequence to replace N tokens being compiled.
\ return address of optimized sequence and u' = number of consumed tokens, or 0 0
: (optimize-tokens)    \ ( tok-addr u -- counted-tokens u' | 0 0 )
   (ip>data>addr) -rot                         \ ( &data tok-addr u      )
   2>r                                         \ ( &data                 ) (R: tok-addr u )
   begin                                       \ ( &data                 ) (R: tok-addr u )
      dup token@ dup                           \ ( &data n n             ) (R: tok-addr u )
   while                \ *-                   \ ( &data n               ) (R: tok-addr u )
      r@ u<=            \   \                  \ ( &data t|f             ) (R: tok-addr u )
   while                \ *  \                 \ ( &data                 ) (R: tok-addr u )
      r2nd@ over        \  \  \                \ ( &data tok-addr &data  ) (R: tok-addr u )
      token+ @          \   \  \               \ ( &data tok-addr xt     ) (R: tok-addr u )
      execute           \    \  \              \ ( &data cnt-tokens|0    ) (R: tok-addr u )
      dup 0=            \    |  |              \ ( &data cnt-tokens|0 t|f) (R: tok-addr u )
   while                \ *  |  |              \ ( &data 0               ) (R: tok-addr u )
      drop token+ cell+ \ |  |  |              \ ( &data'                ) (R: tok-addr u )
   repeat               \ |  |  |              \ ( &data'                ) (R: tok-addr u )
      swap token@       \ *  |  |              \ ( cnt-tokens n          ) (R: tok-addr u )
      2r> 2drop exit    \   /  /               \ ( cnt-tokens n          )
   then                 \  /  /                \ ( &data                 ) (R: tok-addr u )
      0                 \ *  /                 \ ( &data _               ) (R: tok-addr u )
   then                 \   /                  \ ( &data 0               ) (R: tok-addr u )
   nip 0                \ *-                   \ ( 0 0                   ) (R: tok-addr u )
   2r> 2drop                                   \ ( 0 0                   )
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


\ copy and optimize exactly u tokens from XT+offset to HERE. updates HERE.
\ return true if something was optimized, else false
: (optimize-xt,)   \ ( offset u -- t|f )
   false >r                                    \ ( offset u         ) (R: false )
   begin                                       \ ( offset u         ) (R: t|f   )
      dup                                      \ ( offset u u       ) (R: t|f   )
   while                                       \ ( offset u         ) (R: t|f   )
      \ tricky: XT may move, because compiling can reallocate it
      over tokens state @ +                    \ ( offset u src     ) (R: t|f   )
      over                                     \ ( offset u src u   ) (R: t|f   )
      (optimize-tokens,)                       \ ( offset u n t|f'  ) (R: t|f   )
      r@ or r!                                 \ ( offset u n       ) (R: t|f'  )
      tuck -                                   \ ( offset n u'      ) (R: t|f   )
      flip +                                   \ ( u offset'        ) (R: t|f   )
      swap                                     \ ( offset u         ) (R: t|f   )
   repeat                                      \ ( offset 0         ) (R: t|f   )
   2drop r>                                    \ ( t|f              )
;


\ optimize exactly HERE-XT tokens starting from XT. optimized tokens
\ are initially written to HERE and up, then copied back to XT and up.
\ updates HERE. return t if something was optimized, else false
: (optimize-once)    \ ( -- t|f )
   0 state @ here dup >r                     \ ( 0 xt here        ) (R: here )
   sub /token                                \ ( 0 u              ) (R: here )
   (optimize-xt,)                            \ ( t|f              ) (R: here )
   \ optimized code is now between saved HERE and current HERE
   r> state @                                \ ( t|f here xt      )
   over here                                 \ ( t|f here xt here here' )
   sub                                       \ ( t|f here xt u    )
   cmove/count                               \ ( t|f here' xt'    )
   \ optimized code is now between XT and XT'
   nip                                       \ ( t|f xt'          )
   \ so set HERE = XT'
   here - allot                              \ ( t|f              )
;


\ call (optimize-once) repeatedly until there is nothing left optimize. updates HERE.
: (optimize)    \ ( -- )
   begin                                     \ (                  )
      (optimize-once)                        \ ( t|f              )
      0=                                     \ ( flag             )
   until                                     \ (                  )
   [recompile]                               \ (                  )
;


disassemble-upto (optimize-1token)
