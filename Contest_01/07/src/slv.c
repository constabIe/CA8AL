// Status: In Progress

#include <stdio.h>
#include <stdint.h>

uint8_t reverse_bin(uint8_t num);

int main(void) 
{
	uint8_t a, b, c, d;

	scanf("%hhu", &a);
	scanf("%hhu", &b);
	scanf("%hhu", &c);
	scanf("%hhu", &d);

	uint32_t X = 0;

	X = (X | reverse_bin(a)) << 24;
	X = (X | reverse_bin(c)) << 16;
	X = (X | reverse_bin(b)) << 8;
	X = (X | reverse_bin(d));

	printf("%u\n", X);
	// printf("%hhu %hhu %hhu %hhu \n", a, b, c, d);

	return 0;
}

uint8_t reverse_bin(const uint8_t num) 
{
	uint8_t res = 0;
	uint8_t dummy = 0b10000000;

	for (int i = 7; i >= 0; --i)
	{
		res = res | ((num & dummy) >> i);

		dummy = dummy >> 1;
	}

	return res;
}