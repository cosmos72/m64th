\ recursive implementation of fibonacci sequence
: fib \ ( u1 -- u2 )
   dup 2 >
   if
      dup 1- recurse
      swap 2 - recurse
      + exit
   then
   drop 1
;

40 fib .

bye
