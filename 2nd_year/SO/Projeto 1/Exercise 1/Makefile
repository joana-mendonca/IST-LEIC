# Makefile, versao 1
# Sistemas Operativos, DEI/IST/ULisboa 2019-20

CC   = gcc
LD   = gcc
CFLAGS =-g -Wall -pthread -std=gnu99 -I../
LDFLAGS=-lm

# A phony target is one that is not really the name of a file
# https://www.gnu.org/software/make/manual/html_node/Phony-Targets.html
.PHONY: all clean run

all: tecnicofs-nosync tecnicofs-dmutex tecnicofs-drwlock


# Ficheiros executaveis
tecnicofs-dmutex:  lib/bst.c fs-mutex.o main-mutex.o
	$(LD) $(CFLAGS) $(LDFLAGS) -o tecnicofs-dmutex lib/bst.c fs-mutex.o main-mutex.o

tecnicofs-drwlock: lib/bst.c fs-rwlock.o main-rwlock.o
	$(LD) $(CFLAGS) $(LDFLAGS) -o tecnicofs-drwlock lib/bst.c fs-rwlock.o main-rwlock.o

tecnicofs-nosync: lib/bst.c fs.o main.o
	$(LD) $(CFLAGS) $(LDFLAGS) -o tecnicofs-nosync lib/bst.c fs.o main.o

#
lib/bst.o: lib/bst.c lib/bst.h
	$(CC) $(CFLAGS) -o lib/bst.o -c lib/bst.c

fs-mutex.o: fs.c fs.h lib/bst.h
	$(CC) $(CFLAGS) -DMUTEX -o fs-mutex.o -c  fs.c

fs-rwlock.o: fs.c fs.h lib/bst.h
	$(CC) $(CFLAGS) -DRWLOCK -o fs-rwlock.o -c  fs.c
	
fs.o: fs.c fs.h lib/bst.h
	$(CC) $(CFLAGS) -o fs.o -c fs.c

main-mutex.o: main.c fs.h lib/bst.h
	$(CC) $(CFLAGS) -o main-mutex.o -c main.c

main-rwlock.o: main.c fs.h lib/bst.h
	$(CC) $(CFLAGS) -o main-rwlock.o -c main.c

main.o: main.c fs.h lib/bst.h
	$(CC) $(CFLAGS) -o main.o -c main.c


clean:
	@echo Cleaning...
	rm -f lib/*.o *.o tecnicofs-nosync tecnicofs-dmutex tecnicofs-drwlock

run: tecnicofs
	./tecnicofs
