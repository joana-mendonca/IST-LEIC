TARGETS = chat-client chat-server

CC = gcc

CFLAGS = -Wall -Werror -O3 -g

default : $(TARGETS)

%: %.c
	$(CC) $(CFLAGS) -o $@ $<
clean:
	rm -f $(TARGETS)