# synflood Makefile
# Created @ 18.12.2010 by TheFox@fox21.at


VERSION = 2.0.1
CC = gcc
CFLAGS = `libnet-config --defines` `libnet-config --libs` `libnet-config --cflags` -DVERSION=\"$(VERSION)\"


synflood: clean
	$(CC) $(CFLAGS) -o synflood synflood.c

clean:
	rm -f synflood

# EOF
