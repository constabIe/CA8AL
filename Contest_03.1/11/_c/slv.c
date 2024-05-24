#include <stdio.h>
#include <stdint.h>
#include <limits.h>
#include <stdbool.h>
#include <stdlib.h>

#define RESULT_SUCCESS (char *) "YES"
#define RESULT_FAILURE (char *) "NO"

#define EXIT_FAILURE 1

#define VERIFY_CONTRACT(contract, format, ...) \
    do { \
        if (!(contract)) { \
            printf((format), ##__VA_ARGS__ ); \
            exit(EXIT_FAILURE); \
        } \
    } while (0)

 