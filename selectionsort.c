#include <stdio.h>
#include <stdlib.h>

int main(void)
{
    int tamanho;
    do 
        scanf("%d", &tamanho);
    while (tamanho < 2);

    int *vetor = (int *)malloc(tamanho * sizeof(int));
    for(int i = 0; i < tamanho; i++)
        scanf("%d", &vetor[i]);

    for(int i = 0; i < tamanho - 1; i++)
    {
        int min = i;
        for(int j = i + 1; j < tamanho; j++)
            if(vetor[j] < vetor[min])
                min = j;
        int temp = vetor[i];
        vetor[i] = vetor[min];
        vetor[min] = temp;
    }

    for(int i = 0; i < tamanho; i++)
        printf("%d\n", vetor[i]);

    return 0;
}