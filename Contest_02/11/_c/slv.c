#include <stdio.h>
#include <stdint.h>
#include <limits.h>

int main(void) 
{
	int a, b;
	scanf("%d %d", &a, &b);

	int	divinded  = b,
		divisible = a;

	int r_curr, 
		r_prev = divinded;
	int res;

	while (1) {
		r_curr = divisible % divinded;

		if (r_curr == 0) {
			res = r_prev;
			break;
		}

		divisible = divinded;
		divinded  = r_curr;

		r_prev = r_curr;
	} 

	printf("%d\n", res);

	return 0;
}