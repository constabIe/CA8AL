#include <stdio.h>
#include <stdint.h>

int main(void) 
{
	int month, date;

	scanf("%d", &month);
	scanf("%d", &date);

	int day_number = 0;

	day_number += (month - 1) / 2 * (41 + 42);

	if ((month - 1) % 2 != 0) 
	{
		day_number += 41;
	}

	day_number += date;

	printf("%d\n", day_number);

	return 0;
}