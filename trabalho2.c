#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include <ctype.h>
#include <string.h>

typedef enum {
    IEEE_FLOAT,
    IEEE_DOUBLE
} TipoIEEE754;

uint64_t string_para_ieee754(const char *str, TipoIEEE754 tipo) {
    int indice = 0;
    bool negativo = false;

    if (str[indice] == '-') {
        negativo = true;
        indice++;
    } else if (str[indice] == '+') {
        indice++;
    }

    uint64_t parte_inteira = 0;
    while (isdigit(str[indice])) {
        parte_inteira = parte_inteira * 10 + (str[indice] - '0');
        indice++;
    }

    double parte_fracionaria = 0.0;
    if (str[indice] == '.') {
        indice++;
        double divisor = 10.0;
        while (isdigit(str[indice])) {
            parte_fracionaria += (str[indice] - '0') / divisor;
            divisor *= 10.0;
            indice++;
        }
    }

    double numero = parte_inteira + parte_fracionaria;
    if (negativo) numero = -numero;

    if (numero == 0.0) {
        return 0x0000000000000000ULL;
    }

    uint64_t sinal = (numero < 0) ? 1ULL : 0ULL;
    if (numero < 0) numero = -numero;

    int expoente = 0;
    while (numero >= 2.0) {
        numero /= 2.0;
        expoente++;
    }
    while (numero < 1.0) {
        numero *= 2.0;
        expoente--;
    }

    numero -= 1.0;

    uint64_t mantissa = 0;
    int bits_mantissa = (tipo == IEEE_FLOAT) ? 23 : 52;
    int bias = (tipo == IEEE_FLOAT) ? 127 : 1023;

    for (int i = 0; i < bits_mantissa; i++) {
        numero *= 2.0;
        if (numero >= 1.0) {
            mantissa |= (1ULL << (bits_mantissa - 1 - i));
            numero -= 1.0;
        }
    }

    uint64_t expoente_biased = (uint64_t)(expoente + bias);

    if (tipo == IEEE_FLOAT) {
        return (sinal << 31) | (expoente_biased << 23) | mantissa;
    } else {
        return (sinal << 63) | (expoente_biased << 52) | mantissa;
    }
}

int main() {
    const char *entradas[] = {
        "12.25", "-3.5", "0.5", "1.0", "0.0", "-0.0", "+2.75"
    };

    printf("=== Saída float 32 bits ===\n");
    for (int i = 0; i < sizeof(entradas) / sizeof(entradas[0]); i++) {
        uint32_t bits_float = (uint32_t)string_para_ieee754(entradas[i], IEEE_FLOAT);
        float valor_float = *((float *)&bits_float);
        printf("String: %-7s -> Valor float: %.6f\n", entradas[i], valor_float);
    }

    printf("\n=== Saída double 64 bits ===\n");
    for (int i = 0; i < sizeof(entradas) / sizeof(entradas[0]); i++) {
        uint64_t bits_double = string_para_ieee754(entradas[i], IEEE_DOUBLE);
        double valor_double = *((double *)&bits_double);
        printf("String: %-7s -> Valor double: %.6f\n", entradas[i], valor_double);
    }

    return 0;
}
