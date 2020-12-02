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

also m4th-core definitions


\ convert address of counted-tokens to address of tokens and count.
\ analogous to 'count' but for tokens instead of chars
: count-tokens   ( counted-tokens -- tok-addr u )
   dup token+ swap token@
;

\ compile u tokens
: tokens,   ( tok-addr u -- )
   tokens bounds                                ( end-addr addr )
   ?do                                          (               ) ( R: end-addr addr )
      i token@                                  ( token         ) ( R: end-addr addr )
      token,                                    (               ) ( R: end-addr addr )
      1token                                    ( SZt           ) ( R: end-addr addr )
   +loop                                        (               )
;

disassemble-upto count-tokens
