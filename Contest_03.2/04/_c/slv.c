#include <stdio.h>
#include <stdint.h>
#include <limits.h>
#include <stdlib.h>

int main(void) 
{
	FILE *input = fopen("/home/aiavkhadiev/Downloads/Assembly/CA8AL/Contest_03.2/04/data.txt", "r");
	int32_t	el;

	fscanf(input, "%d", &el);
	printf("%d\n", el);

	fclose(input);

	return 0;
} 