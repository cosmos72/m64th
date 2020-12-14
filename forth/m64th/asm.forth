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
also m64th-asm definitions


\ return required len and true if all tokens between XT and HERE
\ can be compiled to native ASM, otherwise false
: xt>asm>n  ( -- u t|f )
   0 here state @                                      ( 0 here xt         )
   ?do                                                 ( u                 )
      i                                                ( u tok-addr        ) ( R: end pos  )
      token>asm>n 0=                                   ( u n|0 t|f         ) ( R: end pos  )
      if                                               ( u 0               ) ( R: end pos  )
        unloop exit                                    ( u false           )
      then                                             ( u n               ) ( R: end pos  )
      +                                                ( u'                ) ( R: end pos  )
      i token@ token>name                              ( u nt              ) ( R: end pos  )
      name>flags flags>consumed-tokens                 ( u n               ) ( R: end pos  )
      1+ tokens                                        ( u consumed_bytes  ) ( R: end pos  )
    +loop                                              ( u                 )
    true                                               ( u true            )
;

disassemble-upto xt>asm>n
