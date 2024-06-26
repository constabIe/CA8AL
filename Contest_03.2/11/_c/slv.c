#include <stdio.h>
#include <stdint.h>
#include <limits.h>

int32_t **get_parameters(FILE *stream, const int32_t m);
int32_t *sequence_generator(const int32_t n);
int32_t *arrcpy(const int *src);
int32_t *transform_sequence(int32_t *seq, int32_t len, int32_t lowerbound, int32_t upperbound);

int main(void) 
{
	FILE *input = fopen("../input.txt", "r");
	FILE *output = fopen("../output.txt", "w");

	int n, m;

	fscanf(input, "%d", &n);
	fscanf(input, "%d", &m);

	int32_t **arr_parameters = get_parameters(input, m);

	int32_t *seq_res = sequence_generator(n);

	for (int i = 0; i < m; ++i)
	{
		seq_res = transform_sequence(seq_res, n, arr_parameters[i][0], arr_parameters[i][1]);
	}

	for (int i = 0; i < n; ++i)
	{
		fprintf(output, "%d ", seq_res[i]);
	}

	fclose(output);
	fclose(input);

	return 0;
}

int32_t **get_parameters(FILE *stream, const int32_t m) 
{
	int32_t **arr_parameters = (int32_t **) malloc(m * sizeof(int32_t *));

	for (int i = 0; i < m; ++i)
	{
		arr_parameters[i] = (int32_t *) malloc(2 * sizeof(int32_t));
	}

	for (int i = 0; i < m; ++i)
	{
		for (int j = 0; j < 2; ++j)
		{
			fscanf(input, "%d", arr_parameters[i][j]);
		}
	}

	return arr_parameters;
}

int32_t *sequence_generator(const int32_t n) {
	int32_t *seq = (int32_t *) malloc(n * sizeof(int32_t));

	for (int i = 0; i < n; ++i)
	{
		seq[i] = i + 1;
	}

	return seq;
}

int32_t *transform_sequence(int32_t *seq, int32_len, int32_t lowerbound, int32_t upperbound) {
	int32_t *transformed_seq = (int32_t *) malloc(n * sizeof(int32_t));
}

