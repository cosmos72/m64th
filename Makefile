FLAGS=-g
#FLAGS=-gdwarf-2 -g3

CC=cc
CFLAGS=-Wall -Wextra -W $(FLAGS)

AS=$(CC)
ASFLAGS=$(FLAGS)

LD=$(CC)
LDFLAGS=$(FLAGS)

OBJS=asm.o cffi.o impl.o m4th.o

all: gen m4th test

clean:
	rm -f gen m4th test *.out ./*.gprof ./*.o ./*~ */*.o */*~ linenoise/linenoise_example linenoise/history.txt

asm.o:  asm.S  $(wildcard *.mh */*.mh */*.S forth/*.S forth/*/*.S)
cffi.o: cffi.c $(wildcard *.h *.mh include/*.h include/*.mh include/*/*.mh c/*.h c/*.c linenoise/*.h linenoise/*.c)
gen.o:  gen.c  $(wildcard *.h *.mh include/*.h include/*.mh include/*/*.mh)
impl.o: impl.c $(wildcard *.h *.mh include/*.h include/*.mh include/*/*.mh)
m4th.o: m4th.c $(wildcard *.h *.mh include/*.h include/*.mh include/*/*.mh)
main.o: main.c $(wildcard *.h *.mh include/*.h include/*.mh include/*/*.mh)
test.o: test.c $(wildcard *.h *.mh include/*.h include/*.mh include/*/*.mh t/*.h t/*.c)

gen: $(OBJS) gen.o
	$(LD) $(LDFLAGS) -o $@ $^

m4th: $(OBJS) main.o
	$(LD) $(LDFLAGS) -o $@ $^

test: $(OBJS) test.o
	$(LD) $(LDFLAGS) -o $@ $^
