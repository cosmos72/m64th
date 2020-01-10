AS=gcc
CC=gcc
ASFLAGS=-g -Wall
CFLAGS=-g -Wall

OBJS=arith.o exec.o main.o mem.o

all: m4th

clean:
	rm -f m4th *.o *~

arith.S: $(wildcard */arith.S)
exec.S:  $(wildcard */exec.S)

m4th: $(OBJS)
	$(CC) $(CFLAGS) -o $@ $^
