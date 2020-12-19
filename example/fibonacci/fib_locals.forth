\ recursive implementation of fibonacci sequence
\ using local variables
: fib {: u -- u' :}
   u 2 >
   if
      u 1- recurse
      u 2 - recurse
      + exit
   then
   1
;

45 fib .

bye
