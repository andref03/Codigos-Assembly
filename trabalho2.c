#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <stdint.h>

#define MAX_BITS 32
#define MAX_FRAC_BITS 30
#define MAX_INT_BITS 32

void inverter_bits(int *vetor, int tamanho) {
    for (int i = 0; i < tamanho / 2; i++) {
        int temp = vetor[i];
        vetor[i] = vetor[tamanho - 1 - i];
        vetor[tamanho - 1 - i] = temp;
    }
}

void imprimir_bits_uint32(uint32_t valor) {
    for (int i = 31; i >= 0; i--) {
        printf("%d", (valor >> i) & 1);
        if (i == 31 || i == 23) printf(" ");
    }
    printf("\n");
}

int main() {
    char entrada[] = "-10.125";
    int bit_sinal = 0;
    if (entrada[0] == '-') {
        bit_sinal = 1;
    }

    // Ignora o sinal
    char *ptr = (entrada[0] == '+' || entrada[0] == '-') ? entrada + 1 : entrada;

    // Separar parte inteira e fracionária
    char *ponto = strchr(ptr, '.');
    char parte_inteira_str[16] = {0}, parte_frac_str[16] = {0};

    if (ponto) {
        strncpy(parte_inteira_str, ptr, ponto - ptr);
        strcpy(parte_frac_str, ponto + 1);
    } else {
        strcpy(parte_inteira_str, ptr);
    }

    // Converte parte inteira para vetor de bits
    int valor_inteiro = atoi(parte_inteira_str);
    int bits_parte_inteira[MAX_INT_BITS];
    int tam_inteiro = 0;

    while (valor_inteiro > 0) {
        bits_parte_inteira[tam_inteiro++] = valor_inteiro % 2;
        valor_inteiro /= 2;
    }
    if (tam_inteiro == 0) bits_parte_inteira[tam_inteiro++] = 0;
    inverter_bits(bits_parte_inteira, tam_inteiro);

    // Converte parte fracionária para vetor de bits
    int bits_parte_fracionaria[MAX_FRAC_BITS];
    int tam_frac = 0;

    if (strlen(parte_frac_str) > 0) {
        double fracionario = atof(parte_frac_str);
        while (fracionario >= 1.0) fracionario /= 10.0;

        for (int i = 0; i < MAX_FRAC_BITS; i++) {
            fracionario *= 2.0;
            if (fracionario >= 1.0) {
                bits_parte_fracionaria[tam_frac++] = 1;
                fracionario -= 1.0;
            } else {
                bits_parte_fracionaria[tam_frac++] = 0;
            }
            if (fracionario == 0.0) break;
        }
    }

    // Normalização
    int expoente_real = 0;
    int mantissa[23] = {0};
    int tam_mantissa = 0;

    if (bits_parte_inteira[0] == 1) {
        expoente_real = tam_inteiro - 1;

        for (int i = 1; i < tam_inteiro && tam_mantissa < 23; i++) {
            mantissa[tam_mantissa++] = bits_parte_inteira[i];
        }
        for (int i = 0; i < tam_frac && tam_mantissa < 23; i++) {
            mantissa[tam_mantissa++] = bits_parte_fracionaria[i];
        }
    } else {
        int pos_1 = -1;
        for (int i = 0; i < tam_frac; i++) {
            if (bits_parte_fracionaria[i] == 1) {
                pos_1 = i;
                break;
            }
        }
        expoente_real = - (pos_1 + 1);
        for (int i = pos_1 + 1; i < tam_frac && tam_mantissa < 23; i++) {
            mantissa[tam_mantissa++] = bits_parte_fracionaria[i];
        }
    }

    int expoente_bias = expoente_real + 127;

    // Montar número final
    uint32_t resultado = 0;
    resultado |= (bit_sinal << 31);
    resultado |= ((uint32_t)expoente_bias & 0xFF) << 23;
    for (int i = 0; i < 23; i++) {
        resultado |= (mantissa[i] & 1) << (22 - i);
    }

    // Interpretar resultado como float
    float *valor_float = (float *)&resultado;

    // Saída
    printf("Entrada: %s\n", entrada);
    printf("Bits IEEE 754: ");
    imprimir_bits_uint32(resultado);
    printf("Valor float interpretado: %.6f\n", *valor_float);

    return 0;
}
