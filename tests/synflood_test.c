
#include "synflood.h"

int main(int argc, char **argv){
	
	printf("%s %d.%d.%d (%s %s)\n", PROJECT_NAME,
		PROJECT_VERSION_MAJOR, PROJECT_VERSION_MINOR, PROJECT_VERSION_PATCH,
		__DATE__, __TIME__);
	printf("%s\n", PROJECT_COPYRIGHT);
	puts("");
	
#ifdef DEBUG
	puts("is DEBUG");
#else
	puts("NOT DEBUG");
#endif
	puts("");
	
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
	
	return EXIT_SUCCESS;
}
