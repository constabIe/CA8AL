#include <stdio.h>
#include <stdint.h>
#include <limits.h>

#define UINT32_LEN (size_t) 32

int main(void) 
{
	uint32_t n, k;
	scanf("%u %u", &n, &k);

	uint32_t template = UINT32_MAX;
	template = template << (UINT32_LEN - k);

	uint32_t val;
	uint32_t max_val = 0;

	for (int i = (UINT32_LEN - k); i >= 0; --i)
	{
		val = (template & n) >> i;

		if (val > max_val) 
		{
			max_val = val;
		}

		template = template >> 1;
	}

	printf("%u", max_val);

	return 0;
}