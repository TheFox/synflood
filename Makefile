# synflood Makefile
# Created @ 18.12.2010 by Christian Mayer <http://fox21.at>

CFLAGS = -Wall `libnet-config --defines` `libnet-config --cflags` -I/usr/local/include -L/usr/local/lib
CLIBS = `libnet-config --libs`
RM = rm -rf


.PHONY: all test clean

all: synflood test

synflood:
	$(CC) --version
	$(CC) $(CFLAGS) -o synflood synflood.c $(CLIBS)

test: synflood
	./synflood

clean:
	$(RM) synflood
