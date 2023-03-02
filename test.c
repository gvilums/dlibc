#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <sys/mman.h>


int main() {

	int* x = malloc(100 * sizeof(int));
	int* y = malloc(20 * sizeof(int));
	free(x);
	x = malloc(50 * sizeof(int));
	free(y);
	free(x);

	int** z = malloc(100 * sizeof(int*));
	for (int i = 0; i < 100; ++i) {
		z[i] = malloc(i * i * sizeof(int));
	}
	
	for (int i = 0; i < 100; ++i) {
		free(z[i]);
	}
	free(z);

	return 10;
}


