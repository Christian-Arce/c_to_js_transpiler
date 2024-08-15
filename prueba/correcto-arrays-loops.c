#include <stdio.h>

int main() {
    // prueba de arrays, condicionales y estructuras anidadas
    int array[5] = {1, 2, 3, 4, 5};
    int matrix[2][3] = {{1, 2, 3}, {4, 5, 6}};

    int i = 0;
    while (i < 5) {
        printf("array[%d] = %d\n", i, array[i]);
        i++;
    }

    int row = 0;
    while (row < 2) {
        int col = 0;
        while (col < 3) {
            printf("matrix[%d][%d] = %d\n", row, col, matrix[row][col]);
            col++;
        }
        row++;
    }

    return 0;
}
