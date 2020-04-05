FLAGS=-g
#FLAGS=-gdwarf-2 -g3

CC=cc
CFLAGS=-Wall -Wextra -W $(FLAGS)

AS=$(CC)
ASFLAGS=$(FLAGS)

LD=$(CC)
LDFLAGS=$(FLAGS)

OBJS=asm.o cffi.o impl.o m4th.o

all: dump m4th test

clean:
	rm -f dump m4th test *.out ./*.gprof ./*.o ./*~ */*.o */*~ linenoise/linenoise_example linenoise/history.txt

asm.o:  asm.S  $(wildcard *.mh */*.mh */*.S)
cffi.o: cffi.c $(wildcard *.h *.mh include/*.h include/*.mh c/*.h c/*.c linenoise/*.c)
dump.o: dump.c $(wildcard *.h *.mh include/*.h include/*.mh)
impl.o: impl.c $(wildcard *.h *.mh include/*.h include/*.mh)
m4th.o: m4th.c $(wildcard *.h *.mh include/*.h include/*.mh)
main.o: main.c $(wildcard *.h *.mh include/*.h include/*.mh)
test.o: test.c $(wildcard *.h *.mh include/*.h include/*.mh t/*.h t/*.c)

dump: $(OBJS) dump.o
	$(LD) $(LDFLAGS) -o $@ $^

m4th: $(OBJS) main.o
	$(LD) $(LDFLAGS) -o $@ $^

test: $(OBJS) test.o
	$(LD) $(LDFLAGS) -o $@ $^
