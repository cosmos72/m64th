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

also m4th-impl
also forth definitions


\ parse syntax "{: in1 in2 ... inn | local1 local2 ... localn -- out1 out2 ... outn :}"
\ and compile code to initialize corresponding local variables
: {:
   0 0 2>r                                     (                      ) ( R: i j )
   begin                                       (                      ) ( R: i j )
      parse-name dup                           ( c-addr u u           ) ( R: i j )
   while                                       ( c-addr u             ) ( R: i j )
      s" :}" string2<>                         ( c-addr u t|f         ) ( R: i j )
   while                                       ( c-addr u             ) ( R: i j )
      s" --" string2<>                         ( c-addr u t|f         ) ( R: i j )
   while                                       ( c-addr u             ) ( R: i j )
      s" |" string2<>                          ( c-addr u t|f         ) ( R: i j )
      if                                       ( c-addr u             ) ( R: i j )
         (local) r1+                           (                      ) ( R: i j')
      else                                     ( c-addr u             ) ( R: i j )
         2drop 2r> ({:found|) 2>r              (                      ) ( R: j' i)
      then                                     (                      ) ( R: i j )
   again                                       ( c-addr u             ) ( R: i j )
   then        \ found "--"                    ( c-addr u             ) ( R: i j )
      (skip-until:})                           ( c-addr u             ) ( R: i j )
   then        \ found ":}"                    ( c-addr u             ) ( R: i j )
   then        \ found end-of-line             ( c-addr u             ) ( R: i j )
   2drop                                       (                      ) ( R: i j )
   0 0 (local) \ mark end of locals            (                      )
   2r>                                         ( i j                  )
   over 0<                                     ( i j t|f              )
   if          \ ^n_before n_after             ( i j                  )
      swap invert                              ( n_after n_before     )
   then                                        ( n_after n_before     )
   swap                                        ( n_before n_after     )
   [compile-locals-enter]                      (                      )
; immediate
