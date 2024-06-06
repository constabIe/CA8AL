#include <stdio.h>
#include <stdint.h>
#include <limits.h>

int32_t *get_parameters(FILE *stream, const int32_t m);
int32_t *sequence_generator(const int32_t n);
int32_t *arrcpy(const int *src);
int32_t *transform_sequence(const int32_t *seq, int32_t lowerbound, int32_t upperbound);

int main(void) 
{
	FILE *input = fopen("../input.txt", "r");
	FILE *output = fopen("../output.txt", "w");

	int n, m;

	fscanf(input, "%d", &n);
	fscanf(input, "%d", &m);

	int32_t *arr_parameters = get_parameters(input, m);

	int32_t *seq_res = sequence_generator(n);
	int32_t *seq_auxiliary = arrcpy(seq_res);

	

	fclose(output);
	fclose(input);

	return 0;
}

