CC=gcc
CFLAGS=-g -Wall -Wextra

AS=$(CC)
ASFLAGS=$(CFLAGS)

OBJS=asm.o m4th.o main.o test.o

all: m4th

clean:
	rm -f m4th *.o *~

asm.o: asm.S $(wildcard */asm.h */*.S)

m4th: $(OBJS)
	$(CC) $(CFLAGS) -o $@ $^
