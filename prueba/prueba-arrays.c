#include <stdio.h>
#include <string.h>

int main() {
    //en caso de no poner punto y coma, nofica y lo traduce igualmente
    int flag = 1
     // error al llamar una variable int como array
    printf("%d", flag[1]);
    int arr[3];
    // error al llamar un array de dimension 1 como dimension 2
    printf("%d", arr[2][1]); 
    
    return 0;
}


