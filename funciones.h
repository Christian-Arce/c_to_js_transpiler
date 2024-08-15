#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>
#include <regex.h>

FILE *output_file;

void create_output_file() {
    output_file = fopen("output_file.js", "w");
    if (!output_file) {
        perror("Error al crear el archivo de salida");
        exit(EXIT_FAILURE);
    }
}

void append_in_jsFile(char *s){
	fputs(s, output_file);
}

void close_output_file() {
    if (output_file) {
        fclose(output_file);
        output_file = NULL;
    } else {
        fprintf(stderr, "Archivo de salida ya está cerrado o nunca se abrió.\n");
    }
}

// Función para verificar si una cadena es un número entero
int is_integer(char *str) {
    char *endptr;
    strtol(str, &endptr, 10);
    return *endptr == '\0'; // Retorna 1 si es un entero, 0 de lo contrario
}

// Función para verificar si una cadena es un número flotante
int is_float(char *str) {
    char *endptr;
    strtof(str, &endptr);
    return *endptr == '\0'; // Retorna 1 si es un flotante, 0 de lo contrario
}

// Función para verificar si una cadena es una cadena de texto (string)
int is_string(char *str) {
    regex_t regex;
    int reti;

    // Compilar la expresión regular para cadenas delimitadas por " " o ' '
    reti = regcomp(&regex, "^(['\"])(.*?)(['\"])$", REG_EXTENDED);
    if (reti) {
        fprintf(stderr, "No se pudo compilar la expresión regular para cadenas\n");
        exit(1);
    }
    reti = regexec(&regex, str, 0, NULL, 0);
    regfree(&regex);
    return !reti; // Retorna 1 si es una cadena de texto, 0 de lo contrario
}



