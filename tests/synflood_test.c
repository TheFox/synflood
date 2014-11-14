
#include "../src/synflood.h"

int main(int argc, char **argv){
	
	printf("%s %d.%d.%d (%s %s)\n", SynFlood_NAME,
		SynFlood_VERSION_MAJOR, SynFlood_VERSION_MINOR, SynFlood_VERSION_PATCH,
		__DATE__, __TIME__);
	printf("%s\n", SynFlood_COPYRIGHT);
	printf("\n");
	
	printf("getuid: %p\n", getuid);
	printf("user: %d\n", getuid());
	printf("atoi(): %p\n", atoi);
	printf("libnet_name2addr4(): %p\n", libnet_name2addr4);
	printf("libnet_init(): %p\n", libnet_init);
	printf("libnet_geterror(): %p\n", libnet_geterror);
	printf("libnet_seed_prand(): %p\n", libnet_seed_prand);
	printf("libnet_build_tcp(): %p\n", libnet_build_tcp);
	printf("libnet_get_prand(): %p\n", libnet_get_prand);
	printf("libnet_build_ipv4(): %p\n", libnet_build_ipv4);
	
	return 0;
}
