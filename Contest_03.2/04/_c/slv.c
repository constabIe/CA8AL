#include <stdio.h>
#include <stdint.h>
#include <limits.h>
#include <stdlib.h>

int main(void) 
{
	FILE *input = fopen("/Users/almiravhadiev/Downloads/HSE/Computer_Architecture_and_Assembly_Language/Assembly_Practice/Contest_03.2/04/data.in", "r");
	int cntr_int = 0;
	int el;

	while (1) {
		int flag = fscanf(input, "%d", &el);

		if (flag == 1) {
			cntr_int++;
		} 
		else if (flag == -1) {
			break;
		}
	}

	printf("%d", cntr_int);

	return 0;
} 