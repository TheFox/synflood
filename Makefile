# synflood Makefile
# Created @ 18.12.2010 by Christian Mayer <http://fox21.at>

CFLAGS = -Wall `libnet-config --defines` `libnet-config --cflags`
CLIBS = `libnet-config --libs`
RM = rm -rf


.PHONY: all test clean

all: synflood

synflood:
	$(CC) --version
	$(CC) $(CFLAGS) -o synflood synflood.c $(CLIBS)

test: synflood
	./synflood

clean:
	$(RM) synflood
