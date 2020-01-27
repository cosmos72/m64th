FLAGS=-g3

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

asm.o:  asm.S  $(wildcard *.mh */*.mh */*.S)
impl.o: impl.c $(wildcard *.h *.mh common/*.h common/*.mh)
m4th.o: m4th.c $(wildcard *.h *.mh common/*.h common/*.mh)
main.o: main.c $(wildcard *.h *.mh common/*.h common/*.mh)
test.o: test.c $(wildcard *.h *.mh common/*.h common/*.mh t/*.h t/*.c)

m4th: $(OBJS) main.o
	$(LD) $(LDFLAGS) -o $@ $^

test: $(OBJS) test.o
	$(LD) $(LDFLAGS) -o $@ $^
