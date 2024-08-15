#include <stdio.h>
#include <string.h>
int a=0;
int main() {
    //en caso de poner punto y coma, nofica y lo traduce igualmente
    int flag = 1;
    int a = flag + "1";
    while(flag<10){
        flag++;
        char a='b';
        if(!flag){
            printf("true\n");
        }else{
            printf("false\n");
        }
    }
    
    return 0;
}
