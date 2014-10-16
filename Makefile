# synflood Makefile
# Created @ 18.12.2010 by Christian Mayer <http://fox21.at>

CFLAGS = `libnet-config --defines` `libnet-config --libs` `libnet-config --cflags`
RM = rm -rf


.PHONY: all test clean

all: synflood

synflood:
	$(CC) $(CFLAGS) -o synflood synflood.c

test: synflood
	./synflood

clean:
	$(RM) synflood
