# Makefile, versao 1
# Sistemas Operativos, DEI/IST/ULisboa 2019-20

SOURCES = main.c fs.c sync.c
SOURCES+= lib/bst.c
#OBJS_NOSYNC = $(SOURCES:%.c=%.o)
#OBJS_MUTEX  = $(SOURCES:%.c=%-mutex.o)
OBJS_RWLOCK = $(SOURCES:%.c=%-rwlock.o)
OBJS = $(OBJS_RWLOCK)
CC   = gcc
LD   = gcc
CFLAGS =-Wall -std=gnu99 -I../ -g
LDFLAGS=-lm -pthread
TARGETS = tecnicofs-rwlock

.PHONY: all clean

all: $(TARGETS)

$(TARGETS):
	$(LD) $(CFLAGS) $^ -o $@ $(LDFLAGS)

### RWLOCK ###
lib/inodes.o: CFLAGS+=-DRWLOCK
lib/inodes.o: lib/inodes.c lib/inodes.h

lib/hash.o: CFLAGS+=-DRWLOCK
lib/hash.o: lib/hash.c lib/hash.h

lib/bst.o: CFLAGS+=-DRWLOCK
lib/bst.o: lib/bst.c lib/bst.h

fs.o: CFLAGS+=-DRWLOCK
fs.o: fs.c fs.h lib/bst.h lib/inodes.h

sync.o: CFLAGS+=-DRWLOCK
sync.o: sync.c sync.h constants.h

main.o: CFLAGS+=-DRWLOCK
main.o: main.c fs.h lib/bst.h constants.h lib/timer.h sync.h lib/hash.h

tecnicofs-rwlock: main.o sync.o fs.o lib/bst.o lib/hash.o lib/inodes.o

%.o:
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	@echo Cleaning...
	rm -f $(OBJS) $(TARGETS)
