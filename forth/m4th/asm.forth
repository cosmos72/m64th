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
also m4th-asm definitions


\ return t if all tokens between XT and HERE can be compiled to native ASM
: xt>asm?   ( -- u t|f )
   0                                                   ( 0                 )
   here 1token - state @  \ skip final 'exit' token    ( 0 here-SZt xt     )
   2dup <=                                             ( 0 here-SZt xt t|f )
   if                                                  ( 0 here-SZt xt     )
      2drop false exit                                 ( 0 false           )
   then                                                ( 0                 )
   do                                                  ( u                 )
      i token@ dup                                     ( u tok tok         ) ( R: end pos  )
      token>asm>n dup invert 0=                        ( u tok n t|f       ) ( R: end pos  )
      if                                               ( u tok n           ) ( R: end pos  )
        unloop 2drop false exit                        ( u false           )
      then                                             ( u tok n           ) ( R: end pos  )
      rot + swap                                       ( u' tok            ) ( R: end pos  )
      token>name name>flags flags>consumed-tokens      ( u n               ) ( R: end pos  )
      1+ tokens                                        ( u consumed_bytes  ) ( R: end pos  )
    +loop                                              ( u                 )
    true                                               ( u true            )
;

disassemble-upto xt>asm?
