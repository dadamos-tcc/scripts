#include <stdio.h>

int main() {

    int limite, p, m;
    do 
        scanf("%d", &limite);
    while (limite < 2); 

    int lista[limite + 1];
    for (p = 2; p <= limite; p++)
        lista[p] = 1;
    
    for (p = 2; p * p <= limite; p++)
        if (lista[p])
            for (m = p * p; m <= limite; m += p)
                lista[m] = 0;

    for (p = 2; p <= limite; p++)
        if (lista[p])
            printf("%d\n", p);

    return 0;
}