# synflood Makefile
# Created @ 18.12.2010 by Christian Mayer <http://fox21.at>

CFLAGS = -Wall `libnet-config --defines` `libnet-config --cflags` -I/usr/local/include -L/usr/local/lib
CLIBS = `libnet-config --libs`
RM = rm -rf
MY_CC_PATH := $(shell which $(CC))


.PHONY: all test clean

all: synflood test

synflood:
	# CC: $(CC)
	# CC path: $(MY_CC_PATH)
	# CC path ls: $(shell ls -l $(MY_CC_PATH))
	@$(CC) --version
	@$(CC) $(CFLAGS) -o synflood synflood.c $(CLIBS)

test: synflood
	./synflood

clean:
	$(RM) synflood
