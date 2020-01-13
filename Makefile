CC=gcc
CFLAGS=-g -Wall -Wextra

AS=$(CC)
ASFLAGS=$(CFLAGS)

OBJS=asm.o m4th.o

all: m4th test

clean:
	rm -f m4th *.o *~

asm.o: asm.S $(wildcard */asm.h */*.S)

m4th: $(OBJS) main.o
	$(CC) $(CFLAGS) -o $@ $^

test: $(OBJS) test.o
	$(CC) $(CFLAGS) -o $@ $^
