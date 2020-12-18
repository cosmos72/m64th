\ sum the numbers from 0 to u-1
: sum-n  ( u -- u' )
  dup if
    0 tuck do i + loop
  then
;

1000000000 sum-n .
