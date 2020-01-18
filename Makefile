FLAGS=-g

CC=cc
CFLAGS=-Wall -Wextra -W $(FLAGS)

AS=$(CC)
ASFLAGS=$(CFLAGS)

OBJS=asm.o m4th.o

all: m4th test

clean:
	rm -f m4th test *.o *~

asm.o:  asm.S $(wildcard *asm.h */asm.h */*.S)
impl.o: impl.c $(wildcard *.h)
m4th.o: m4th.c $(wildcard *.h)
main.o: main.c $(wildcard *.h)
test.o: test.c $(wildcard *.h)

m4th: $(OBJS) main.o
	$(CC) $(CFLAGS) -o $@ $^

test: $(OBJS) test.o
	$(CC) $(CFLAGS) -o $@ $^
