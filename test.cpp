
int main() {

	int* x = new int[100];
	int* y = new int[20];

	delete[] x;

	x = new int[50];

	delete[] y;
	delete[] x;

	int** z = new int*[50];
	for (int i = 0; i < 100; ++i) {
		z[i] = new int[i * i];
	}
	
	for (int i = 0; i < 100; ++i) {
		delete[] z[i];
	}
	delete[] z;

	return 0;
}


