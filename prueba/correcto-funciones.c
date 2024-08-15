#include <stdio.h>
int suma(int a, int b) {
    return a + b;
}

int multiplica(int a, int b) {
    return a * b;
}

int main() {
    //prueba de declaracion y llamada a funciones
    int num1 = 5;
    int num2 = 3;

    int resultadoSuma = suma(num1, num2);
    printf("La suma de %d y %d es: %d\n", num1, num2, resultadoSuma);

    int resultadoMultiplica = multiplica(num1, num2);
    printf("La multiplicación de %d y %d es: %d\n", num1, num2, resultadoMultiplica);

    return 0;
}