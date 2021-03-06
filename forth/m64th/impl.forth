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

also m64th-core
also m64th-impl definitions


\ find an optimized sequence to replace a single token being compiled.
: (optimize-1token)   ( tok-addr -- counted-tokens | 0 )
   (ip>data) 1token - bounds                     ( tok-addr data-end data  )
   rot token@ -rot                               ( tok      data-end data  )
   do                                            ( tok                     ) ( R: data-end data )
      dup i token@ =                             ( tok t|f                 ) ( R: data-end data )
      if                                         ( tok                     ) ( R: data-end data )
         drop i token+ unloop                    ( counted-tokens          )
         exit                                    ( counted-tokens          )
      then                                       ( tok                     ) ( R: data-end data )
      4 tokens                                   ( tok 4*SZt               ) ( R: data-end data )
   +loop                                         ( tok                     )
   drop 0      \ no optimization found           ( 0                       )
;


\ find an optimized sequence to replace two tokens being compiled.
: (optimize-2token)      ( tok-addr -- counted-tokens | 0 )
   (ip>data>addr) swap                           ( hashmap tok-addr        )
   dup token@ swap token[1]                      ( hashmap tok0 tok1       )
   8 tokens lshift or                            ( hashmap tok0|tok1<<16   ) \ key = tok0|tok1<<16
   hashmap-find/int                              ( key' &val|0             )
   nip                                           ( &val|0                  )
;


\ find a low-priority optimized sequence to replace two tokens being compiled.
: (optimize-2token-lowprio)   ( tok-addr -- counted-tokens|0 )
   (ip>data>addr) swap                           ( &data addr addr       )
   uint@           \ assumes 1uint == 2 tokens   ( &data tok0|tok1<<16   )
   >r                                            ( &data                 ) ( R: key )
   begin                                         ( &data                 ) ( R: key )
      dup uint@    \ assumes 1uint == 2 tokens   ( &data tok0|tok1<<16   ) ( R: key )
      dup                                        ( &data tok0|tok1<<16 fl) ( R: key )
   while                                         ( &data tok0|tok1<<16   ) ( R: key )
      r@ <>                                      ( &data t|f             ) ( R: key )
   while                                         ( &data                 ) ( R: key )
      4 tokens +                                 ( &data'                ) ( R: key )
   repeat                                        ( &data                 ) ( R: key )
      0 swap uint+ \ assumes 1uint == 2 tokens   ( 0 counted-tokens      ) ( R: key )
   then                                          ( _ counted-tokens|0    ) ( R: key )
   nip r> drop                                   ( counted-tokens|0      )
;


\ find an optimized sequence to replace three tokens being compiled.
: (optimize-3token)      ( tok-addr -- counted-tokens | 0 )
   (ip>data>addr) swap dup >r                    ( hashmap tok-addr               ) ( R: tok-addr )
   token@ r@ token[1]                            ( hashmap tok0 tok1              ) ( R: tok-addr )
   8 tokens lshift or                            ( hashmap tok0|tok1<<16          ) ( R: tok-addr )
   r> token[2]                                   ( hashmap tok0|tok1<<16 tok2     )
   16 tokens lshift or                           ( hashmap tok0|tok1<<16|tok2<<32 )
   hashmap-find/cell                             ( key' &val|0                    )
   nip                                           ( &val|0                         )
;


\ find an optimized sequence to replace three tokens being compiled,
\ which may be part of control flow i.e. 'if' 'else' 'case' etc.
\ if no optimized sequence was found, return 0
: (optimize-3jump)   ( tok-addr -- counted-tokens|0 )
   (ip>data>addr) swap dup                       ( &data addr addr     )
   token@ swap token[2]                          ( &data tok0 tok2     )
   8 tokens lshift                               ( &data tok0 tok2<<16 )
   or >r                                         ( &data               ) ( R: key )
   begin                                         ( &data               ) ( R: key )
      dup token@ dup                             ( &data tok0 tok0     ) ( R: key )
   while                                         ( &data tok0          ) ( R: key )
      over token[1]                              ( &data tok0 tok2     ) ( R: key )
      8 tokens lshift or                         ( &data tok0|tok2<<16 ) ( R: key )
      r@ <>                                      ( &data t|f           ) ( R: key )
   while                                         ( &data               ) ( R: key )
      4 tokens +                                 ( &data'              ) ( R: key )
   repeat                                        ( &data               ) ( R: key )
      0 swap token+ token+                       ( 0 counted-tokens    ) ( R: key )
   then                                          ( _ counted-tokens|0  ) ( R: key )
   nip r> drop                                   ( counted-tokens|0    )
;


\ find an optimized sequence to replace N tokens being compiled.
\ return address of optimized sequence and u' = number of consumed tokens, or 0 0
: (optimize-tokens)      ( tok-addr u opts -- counted-tokens u' | 0 0 )
   (ip>data>addr) swap -rot                      ( &data tok-addr u      ) ( R: opts            )
   2>r                                           ( &data                 ) ( R: opts tok-addr u )
   begin                                         ( &data                 ) ( R: opts tok-addr u )
      dup token@ dup                             ( &data n+opt n+opt     ) ( R: opts tok-addr u )
      r3rd@ and                                  ( &data n+opt opt|0     ) ( R: opts tok-addr u )
      swap >char dup                             ( &data opt|0 n n       ) ( R: opts tok-addr u )
   while                \ *-                     ( &data opt|0 n         ) ( R: opts tok-addr u )
      r@ u<=            \   \                    ( &data opt|0 t|f       ) ( R: opts tok-addr u )
   while                \ *  \                   ( &data opt|0           ) ( R: opts tok-addr u )
      if                \  \  \                  ( &data                 ) ( R: opts tok-addr u )
         r2nd@ over     \   \  \                 ( &data tok-addr &data  ) ( R: opts tok-addr u )
         token+ @       \    \  \                ( &data tok-addr xt     ) ( R: opts tok-addr u )
         execute        \    |  |                ( &data cnt-tokens|0    ) ( R: opts tok-addr u )
      else              \    |  |                ( &data                 ) ( R: opts tok-addr u )
         0              \    |  |                ( &data 0               ) ( R: opts tok-addr u )
      then              \    |  |                ( &data cnt-tokens|0    ) ( R: opts tok-addr u )
      dup 0=            \    |  |                ( &data cnt-tokens|0 t|f) ( R: opts tok-addr u )
   while                \ *  |  |                ( &data 0               ) ( R: opts tok-addr u )
      drop token+ cell+ \ |  |  |                ( &data'                ) ( R: opts tok-addr u )
   repeat               \ *  |  |                ( &data cnt-tokens      ) ( R: opts tok-addr u )
      swap token@ >char \    |  |                ( cnt-tokens n          ) ( R: opts tok-addr u )
      2r> 2drop         \   /  /                 ( cnt-tokens n          ) ( R: opts            )
      r> drop exit      \  /  /                  ( cnt-tokens n          )
   then                 \ *  /                   ( &data opt|0           ) ( R: opts tok-addr u )
      0                 \   /                    ( &data opt|0 _         ) ( R: opts tok-addr u )
   then                 \ *-                     ( &data opt|0 n         ) ( R: opts tok-addr u )
   nip 2drop 0 0        \                        ( 0 0                   ) ( R: opts tok-addr u )
   2r> 2drop                                     ( 0 0                   ) ( R: opts            )
   r> drop                                       ( 0 0                   )
;


\ compile consumed IP at src after a token 'if' 'else' 'while' etc.
: (token-consumed-ip,)    ( src tok -- u )
   token>name dup 0=                             ( src nt|0 t|f             )
   if                                            ( src 0                    )
      nip exit                                   ( 0                        )
   then                                          ( src nt                   )
   name>flags flags>consumed-tokens              ( src u                    )
   tuck 0                                        ( u src u 0                )
   ?do                                           ( u src         ) ( R: u i  )
      dup token@ token,                          ( u src         ) ( R: u i  )
      token+                                     ( u src'        ) ( R: u i  )
   loop                                          ( u src                    )
   drop                                          ( u                        )
;


\ copy and optimize at least one token from src to HERE. updates HERE.
\ return number of consumed tokens, and true if an optimized sequence was found, else false.
: (optimize-tokens,)    ( src u opts -- u' t|f )
   over 0=                                       ( src u opts t|f           )
   if                                            ( src 0 opts               )
      drop nip false exit                        ( 0 false                  )
   then                                          ( src u opts               )
   >r trail r>                                   ( src src u opts           )
   (optimize-tokens)                             ( src countedtokens|0 iu|0 )
   swap dup                                      ( src iu|0 countedtokens|0 )
   if                                            ( src iu countedtokens     )
      flip                                       ( countedtokens iu src     )
      over tokens +                              ( countedtokens iu src'    )
      rot dup countedtokens,                     ( iu src countedtokens     )
      countedtokens>last                         ( iu src tok|_missing_     )
      (token-consumed-ip,) + true                ( iu' true                 )
   else                                          ( src 0 0                  )
      2drop dup token+                           ( src src'                 )
      swap token@ dup token,                     ( src' tok                 )
      (token-consumed-ip,)                       ( iu                       )
      1+ false                                   ( iu' false                )
   then                                          ( iu t|f                   )
;


\ copy and optimize exactly u tokens from XT+offset to HERE. updates HERE.
\ return true if something was optimized, else false
: [optimize-xt,]     ( offset u opts -- t|f )
   false 2>r                                     ( offset u         ) ( R: opts false )
   begin                                         ( offset u         ) ( R: opts t|f   )
      dup                                        ( offset u u       ) ( R: opts t|f   )
   while                                         ( offset u         ) ( R: opts t|f   )
      \ tricky: XT may move, because compiling can reallocate it
      over tokens state @ +                      ( offset u src     ) ( R: opts t|f   )
      over                                       ( offset u src u   ) ( R: opts t|f   )
      r2nd@ (optimize-tokens,)                   ( offset u n t|f'  ) ( R: opts t|f   )
      r@ or r!                                   ( offset u n       ) ( R: opts t|f'  )
      tuck -                                     ( offset n u'      ) ( R: opts t|f   )
      flip +                                     ( u offset'        ) ( R: opts t|f   )
      swap                                       ( offset u         ) ( R: opts t|f   )
   repeat                                        ( offset 0         ) ( R: opts t|f   )
   2drop r> r> drop                              ( t|f              )
;


\ optimize exactly HERE-XT tokens starting from XT. optimized tokens
\ are initially written to HERE and up, then copied back to XT and up.
\ updates HERE. return t if something was optimized, else false
: [optimize-once]      ( opts -- t|f )
   0 state @ here dup >r                       ( opts 0 xt here   ) ( R: here )
   sub /token rot                              ( 0 u opts         ) ( R: here )
   [optimize-xt,]                              ( t|f              ) ( R: here )
   \ optimized code is now between saved HERE and current HERE
   r> state @                                  ( t|f here xt      )
   over here                                   ( t|f here xt here here' )
   sub                                         ( t|f here xt u    )
   cmove/count                                 ( t|f here' xt'    )
   \ optimized code is now between XT and XT'
   nip                                         ( t|f xt'          )
   \ so set HERE = XT'
   here - allot                                ( t|f              )
;


\ call [optimize-once] repeatedly until there is nothing left optimize. updates HERE.
: [optimize]      ( opts -- )
   begin                                       ( opts             )
      dup [optimize-once]                      ( opts t|f         )
      0=                                       ( opts flag        )
   until                                       ( opts             )
   drop [recompile]                            (                  )
;


\ parse names and skip them until :} is found
: (skip-until:})     ( -- )
  0 0
  begin
     2drop                                     (                  )
     parse-name dup                            ( c-addr u u       )
  while                                        ( c-addr u         )
     s" :}" string2=                           ( c-addr u t|f     )
  until                                        ( c-addr u         )
  then                                         ( c-addr u         )
  2drop                                        (                  )
;


\ update {: internal state to remember that | was found
: ({:found|)    ( i j -- ^j i )
   invert swap                                 ( j' i             )
   dup 0<                                      ( j' i t|f         )
   if           \ found a second "|"           ( j' i             )
      -22 throw \ CONTROL_STRUCTURE_MISMATCH
   then                                        ( j i              )
;


disassemble-upto (optimize-1token)
