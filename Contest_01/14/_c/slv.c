#include <stdio.h>
#include <stdint.h>
#include <limits.h>

int main(void) 
{
	int n, m, k, d, x, y;

	int s = n * m;
	int beet_q = s * k;
	int box_q = beet_q / d; 

	if (beet_q % d != 0) { // CF (carry flag)
		++box_q;
	}

	
	
}