#include <stdio.h>
#include <stdint.h>
#include <limits.h>

int main(void) 
{
	uint8_t a, b, c, d;

	scanf("%hhu", &a);
	scanf("%hhu", &b);
	scanf("%hhu", &c);
	scanf("%hhu", &d);

	
	uint32_t X = 0;

	X = (X | d) << 8;
	X = (X | c) << 8;
	X = (X | b) << 8;
	X = (X | a) << 0;

	printf("%u\n", X);

	return 0;
}