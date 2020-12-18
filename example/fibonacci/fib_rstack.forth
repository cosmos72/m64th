\ recursive implementation of fibonacci sequence
\ using return stack
: fib   ( u1 -- u2 )
   dup >r
   2 >
   if
      r@ 1- recurse
      r> 2 - recurse
      + exit
   then
   r> drop 1
;

40 fib .

bye
