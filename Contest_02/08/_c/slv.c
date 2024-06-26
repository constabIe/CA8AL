#include <stdio.h>
#include <stdint.h>
#include <limits.h>
#include <stdlib.h>

#define EXIT_FAILURE 1

#define BRED  "\033[1;31m"
#define RESET "\033[0m"

#define VERIFY_CONTRACT(contract, format, ...) \
    do { \
        if (!(contract)) { \
            printf((format), ##__VA_ARGS__ ); \
            exit(EXIT_FAILURE); \
        } \
    } while (0)


typedef struct 
{ 
	int **data;
 	int rows_q; 
 	int cols_q; 
 						
} Matrix_t;	

Matrix_t* allocate_matrix(const int rows_q, const int cols_q); 
void deallocate_matrix(Matrix_t *matrix); 

void matrix_scanf(Matrix_t *dest_matrix); 
void matrix_printf(Matrix_t *source_matrix);

Matrix_t *matrix_product_operation(const Matrix_t *opearnd_1, const Matrix_t *opearnd_2); 	

int main(void) 
{
	int n, m, k;
	VERIFY_CONTRACT(scanf("%d %d %d", &n, &m, &k) == 3, "\nInvalid data input\n");

	Matrix_t *matrix_operand_1 = allocate_matrix(n, m);
	Matrix_t *matrix_operand_2 = allocate_matrix(m, k);

	matrix_scanf(matrix_operand_1);
	matrix_scanf(matrix_operand_2);	

	Matrix_t *matrixes_product_result = matrix_product_operation(matrix_operand_1, matrix_operand_2);

	matrix_printf(matrixes_product_result);

	deallocate_matrix(matrix_operand_1);
	deallocate_matrix(matrix_operand_2);

	return 0;
}

Matrix_t* allocate_matrix(const int rows_q, const int cols_q) 
{
	Matrix_t *matrix = (Matrix_t *) malloc(sizeof(Matrix_t));

	matrix->rows_q = rows_q;
	matrix->cols_q = cols_q;

	matrix->data = (int **) malloc(matrix->rows_q * sizeof(int *));
	VERIFY_CONTRACT(matrix->data != NULL, "\nUnable to allocate memory\n");

	for (int i = 0; i < matrix->rows_q; ++i)
	{
		matrix->data[i] = (int *) malloc(matrix->cols_q * sizeof(int));
		VERIFY_CONTRACT(matrix->data[i] != NULL, "\nUnable to allocate memory\n");
	}

	return matrix;
}

void deallocate_matrix(Matrix_t *matrix) 
{
	for (int i = 0; i < matrix->rows_q; ++i)
	{
		free(matrix->data[i]);
	}

	free(matrix->data);
	free(matrix);
}

void matrix_scanf(Matrix_t *dest_matrix) 
{
	for (int i = 0; i < dest_matrix->rows_q; ++i)
	{
		for (int j = 0; j < dest_matrix->cols_q; ++j)
		{
			VERIFY_CONTRACT(scanf("%d", &dest_matrix->data[i][j]) == 1, "\nInvalid data input"\n);
		}
	}
}

void matrix_printf(Matrix_t *source_matrix) 
{
	printf("\n\n");

	for (int i = 0; i < source_matrix->rows_q; ++i)
	{
		for (int j = 0; j < source_matrix->cols_q; ++j)
		{
			printf(" %d", source_matrix->data[i][j]);
		}
		printf("\n");
	}
}

Matrix_t *matrix_product_operation(const Matrix_t *opearnd_1, const Matrix_t *opearnd_2) 
{
	VERIFY_CONTRACT(opearnd_1->cols_q == opearnd_2->rows_q, "\nUnable to perfom operation. Invalid matrix size\n");

	int rows_q_result_matrix = opearnd_1->rows_q;
	int cols_q_result_matrix = opearnd_2->cols_q;

	Matrix_t *result_matrix = allocate_matrix(rows_q_result_matrix, cols_q_result_matrix);

	int cell_itterations_q = opearnd_1->cols_q & opearnd_2->rows_q;

	for (int i = 0; i < result_matrix->rows_q; ++i)
	{	
		for (int j = 0; j < result_matrix->cols_q; ++j)
		{
			for (int w = cell_itterations_q - 1; w >= 0; --w)
			{
				result_matrix->data[i][j] += opearnd_1->data[i][w] * opearnd_2->data[w][j];
			}
		}
	}

	return result_matrix;
}
