CC=gcc
CFLAGS=-g -Wall

AS=$(CC)
ASFLAGS=$(CFLAGS)

OBJS=arith.o exec.o main.o mem.o

all: m4th

clean:
	rm -f m4th *.o *~

arith.o: arith.S $(wildcard */asm.h */arith.S)
exec.o:  exec.S  $(wildcard */asm.h */exec.S)

m4th: $(OBJS)
	$(CC) $(CFLAGS) -o $@ $^
