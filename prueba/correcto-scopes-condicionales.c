#include <stdio.h>

int main() {
    //prueba condicionales y definicion de variables en diferentes scopes
    int x = 10;
    printf("Valor de x en el scope principal: %d\n", x);

    if (x > 0) {
        int x = 20;
        printf("Valor de x en el scope del bloque if: %d\n", x);
    }
    else{
        printf("else");
    }

    printf("Valor de x después del bloque if: %d\n", x);

    return 0;
}
