CC=gcc
CFLAGS=-g -Wall

AS=$(CC)
ASFLAGS=$(CFLAGS)

OBJS=asm.o main.o mem.o

all: m4th

clean:
	rm -f m4th *.o *~

asm.o: asm.S $(wildcard */asm.h */*.S)

m4th: $(OBJS)
	$(CC) $(CFLAGS) -o $@ $^
