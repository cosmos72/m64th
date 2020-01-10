AS=gcc
CC=gcc
ASFLAGS=-g -Wall
CFLAGS=-g -Wall

all: m4th

clean:
	rm -f m4th *.o *~

m4th: arith_amd64.o exec_unix_amd64.o main.o mem_unix.o
	$(CC) $(CFLAGS) -o $@ $^
