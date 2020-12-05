\ collatz conjecture
: collatz ( u -- )
   begin            ( u     )
      dup 1 and     ( u t|f )
      if            ( u     )
         3 * 1+     ( u'    )
      then          ( u     )
      2/            ( u'    )
      dup 1 =       ( u t|f )
   until            ( u     )
   drop             (       )
;

1000 collatz

bye
