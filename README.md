# synflood
Start a SYN flood attack to an ip address.

## Requirements
- libnet1. "libnet1-dev" under Debian.
- Root access for sending a packet.
- Its recommended to block all RST packets from the source host on the source host.

		iptables -I OUTPUT -p tcp --dport 80 --tcp-flags RST RST -j DROP
		iptables -I OUTPUT -p tcp --dport 80 --tcp-flags RST ACK -j DROP
