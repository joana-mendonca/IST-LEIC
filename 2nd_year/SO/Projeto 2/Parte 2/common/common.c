#include "common.h"

// makes a pipes with the given pathname and
// returns the result of open for reading
int make_pipe(char const *pipename) {

    // remove pipe if it does not exist
    if (unlink(pipename) != 0 && errno != ENOENT) {
        fprintf(stderr, "[ERR]: unlink(%s) failed: %s\n", pipename,
                strerror(errno));
        return -1;
    }

    // create pipe
    if (mkfifo(pipename, 0640) != 0) {
        fprintf(stderr, "[ERR]: mkfifo failed: %s\n", strerror(errno));
        return -1;
    }

    return 0;
}

int power(int base, int pot) {

    if (pot == 0)
        return 1;
    
    int res = base;

    for (int i = 1; i < pot; i++)
        res *= base;

    return res;
}

// aux function to encode_int
int get_char(int num_bin[], int byte) {

    int res = 0;
    int pot = 7;
    int bit = byte * 8;
    for (int i = bit; i < (byte + 1) * 8; i++) {
        if (num_bin[i] != 0) res += power(2, pot);
        pot--;
    }

    return res;
}

// encodes the int into the string
void encode_int(int num, char *encoded_int) {
    
    int is_negative = 0;
    
    if (num < 0){
        is_negative = 1;
        num *= -1;
    }

    int num_bin[8 * sizeof(int)] = {0};

    for (int i = 8 * sizeof(int) - 1; num > 0; i--) {
        num_bin[i] = num % 2;
        num /= 2;
    }

    num_bin[0] = is_negative;

    for (int i = 0; i < sizeof(int); i++)
        encoded_int[i] = get_char(num_bin, i);
}

int decode_int(char *encoded_int) {

    int num_bin[8 * sizeof(int)] = {0};

    for (int byte = 0; byte < sizeof(int); byte++) {
        int encoded_byte = encoded_int[byte];

        if (encoded_byte < 0) encoded_byte += 256;

        for (int i = 8 * (byte + 1) - 1; i >= 8 * byte; i--) {
            num_bin[i] = encoded_byte % 2;
            encoded_byte /= 2;
        }
    }

    int is_negative = num_bin[0];

    int decoded_int = 0;
    int pot = 30;
    for (int i = 1; i < 8 * sizeof(int); i++) {
        if (num_bin[i] != 0) decoded_int += power(2, pot);
        pot--;
    }

    if (is_negative)
        decoded_int *= -1;

    return decoded_int;
}

// writes str with len in main_str starting from start
void compose_msg(char *main_str, char const *str, int start, int len) {

    int i = 0;
    for (int j = start; j < start + len; j++) {
        main_str[j] = str[i];
        i++;
    }
}
