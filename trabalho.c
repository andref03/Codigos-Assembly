#include <stdio.h>
#include <stdint.h>

// função auxiliar: converte um caractere para valor numérico de 0 a 9
int char_para_digito(char c) {
    if (c >= '0' && c <= '9') {
        return c - '0';
    }
    return -1; // inválido, caractere não é dígito
}

// converte string para inteiro
long string_to_int(const char *str) {
    long resultado = 0;
    int sinal = 1;
    int digito;

    // verifica o primeiro caractere (identificando se é sinal)
    if (*str == '-') {
        sinal = -1;
        str++;
    } else if (*str == '+') {
        str++;
    }

    // loop de conversão
    while (*str != 0) { // até encontrar NULL
        digito = char_para_digito(*str);
        if (digito == -1) {
            break; // caractere inválido, para de processar
        }

        resultado = resultado * 10 + digito;
        str++;
    }

    return sinal * resultado;
}

int main() {

    const char *entrada = "+13";
    printf("Entrada: \"%s\" → Saída: %ld\n", entrada, string_to_int(entrada));

    return 0;
}
