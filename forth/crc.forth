\ adapted from https://www.rosettacode.org/wiki/CRC-32#Forth

: crc/ \ ( n -- n )
   8 0 do dup 1 rshift swap 1 and
   if $edb88320 xor then loop ;

: crc-fill
   256 0 do i crc/ , loop
;

create crc-table crc-fill

: crc+ \ ( crc n -- crc' )
   over xor $ff and cells crc-table + @
   swap 8 rshift xor
;

: crc-string+ \ ( crc str len -- crc' )
   bounds ?do i c@ crc+ loop
;

: 100M 't' $ffffffff 100000000 0 do over crc+ loop nip ;

100M

bye
