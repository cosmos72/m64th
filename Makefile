FLAGS=-g

CC=cc
CFLAGS=-Wall -Wextra -W $(FLAGS)

AS=$(CC)
ASFLAGS=$(FLAGS)

LD=$(CC)
LDFLAGS=$(FLAGS)

OBJS=asm.o impl.o m4th.o

all: m4th test

clean:
	rm -f m4th test ./*.o ./*~ */*.o */*~

asm.o:  $(wildcard *.mh *.S */*.mh */*.S)
impl.o: impl.c $(wildcard *.h)
m4th.o: m4th.c $(wildcard *.h)
main.o: main.c $(wildcard *.h)
test.o: test.c $(wildcard *.h t/*.h t/*.c)

m4th: $(OBJS) main.o
	$(LD) $(LDFLAGS) -o $@ $^

test: $(OBJS) test.o
	$(LD) $(LDFLAGS) -o $@ $^
