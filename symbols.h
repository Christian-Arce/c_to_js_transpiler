#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define FUNC 0 // identificamos functions con 0
#define VAR 1 // identificamos variables con 1

typedef struct Scope {
    int scope;
    struct Scope* next;
} Scope;

Scope* createScope(int scope) {
    Scope* newScope = (Scope*)malloc(sizeof(Scope));
    if (!newScope) {
        printf("Error al asignar memoria\n");
    }
    newScope->scope = scope;
    newScope->next = NULL;
    return newScope;
}

void push(Scope** top, int scope) {
    Scope* newScope = createScope(scope);
    newScope->next = *top;
    *top = newScope;
}

void pop(Scope** top) {
    if (*top == NULL) {
        printf("La pila está vacía\n");
    }
    Scope* temp = *top;
    *top = (*top)->next;
    int popped = temp->scope;
    free(temp);
}

int peek(Scope* top) {
    if (top == NULL) {
        printf("La pila está vacía\n");
        return -1;
    }
    return top->scope;
}

typedef struct {
    char *type;
    char *value;
} DataTypeValue;

// estructura de un simbolo
typedef struct symbol {
    char *name;
    char *data_type;
    int symbol_type;
    int is_const;
    int arguments; // para funciones
    int dimension; // 1 para arrays, 2 para matriz, 0 para otro
    int line_of_declaration; // linea del cod donde se declara el simbolo
    int scope; // nro unico del scope
    struct symbol *next; // siguiente simbolo de la lista
}symbol;

symbol* table = NULL;
Scope* scope_stack=NULL;

void print_symbolTable() {
    symbol *symbl = table;
    printf("Tabla de Simbolos:\n");
    printf("------------------------------------------------------------------------------------------------------------------\n");
    printf("| %-10s | %-10s | %-12s | %-10s | %-8s   | %-4s | %-10s | %s  \n", "Tipo", "Nombre", "Constancia", "Tipo de dato", "Dimension", "Args", "Scope", "Linea de declaracion");
    printf("------------------------------------------------------------------------------------------------------------------\n");

    while (symbl != NULL) {
        if (symbl->symbol_type == VAR) {
            printf("| %-10s | %-10s | %-12s | %-12s | %-12d | %-3d | %-10d | %d\n",
                "VAR",
                symbl->name,
                symbl->is_const ? "constante" : "no constante",
                symbl->data_type,
                symbl->dimension,
                symbl->arguments,
                symbl->scope,
                symbl->line_of_declaration);
        } else { // funcion
            printf("| %-10s | %-10s | %-12s | %-12s | %-12d | %-3d | %-5s | %-2d\n",
                "FUNC",
                symbl->name,
                symbl->is_const ? "constante" : "no constante",
                symbl->data_type,
                symbl->dimension,
                symbl->arguments,
                "No aplica",
                symbl->line_of_declaration);
        }
        symbl = symbl->next;
    }
    printf("-------------------------------------------------------------------------------------------------------------------\n");
}


symbol *get_symbol(char *name){
    for (symbol *s = table; s; s = s->next) {
        if (strcmp(s->name, name) == 0) {
            return s;
        }
    }
    return NULL;
}

int check_scope(char *symbl_name, int scope, int line_of_declaration){
    symbol *sym=get_symbol(symbl_name);
    if(sym!=NULL){
        if(sym->scope!=scope){
            return 0;
        }else{
            printf("Scope error linea %d: ya existe var %s en este scope\n", line_of_declaration, symbl_name);
            return 1;
        }
    }else{
        return -1;
    }
}

int put_symbol(char *name, char *type, int is_const, int arguments, int dimension, int symbol_type, int line_of_declaration) {
    int is_in_scope=check_scope(name, peek(scope_stack), line_of_declaration);
    symbol *sym = (symbol *) malloc(sizeof(symbol));
    sym->name = strdup(name);
    sym->data_type = type;
    sym->is_const=is_const;
    sym->symbol_type=symbol_type;
    sym->arguments = arguments;
    sym->dimension = dimension;
    sym->line_of_declaration=line_of_declaration;
    sym->next = table;
    table = sym;
    sym->scope=peek(scope_stack);

    return is_in_scope;
}

void check_arguments(char *function_name, int cant_arguments, int line){
    symbol *actual_symbol=get_symbol(function_name);
    if(actual_symbol->arguments!=cant_arguments){
        printf("Error de argumentos en la linea %d: cantidad de argumentos incorrectos para la funcion %s\n", line, function_name);
    }

}

void check_dimension(char *name, int dimension_counter, int line){
    symbol *actual_symbl=get_symbol(name);
    if(actual_symbl->dimension==0){
        printf("Error de dimension en la linea %d: %s no es un array\n", line, name);
    }else if(actual_symbl->dimension!=dimension_counter){
        printf("Error de dimension en la linea %d: %s array pero se le llama con dimension incorrecta\n", line, name);
    }
}

DataTypeValue* create_data_type_value(const char *type, const char *value) {
    DataTypeValue *dtv = (DataTypeValue *)malloc(sizeof(DataTypeValue));
    dtv->type = strdup(type);
    dtv->value = strdup(value);
    return dtv;
}

DataTypeValue* get_data_type(char *name) {
    symbol *sym = get_symbol(name);
    if (sym) {
        return create_data_type_value(sym->data_type, name);
    } else {
        if (is_integer(name)) {
            return create_data_type_value("int", name);
        } else if (is_float(name)) {
            return create_data_type_value("float", name);
        } else if (is_string(name)) {
            return create_data_type_value("string", name);
        } else {
            return create_data_type_value("unknown", name);
        }
    }
}

void check_type(DataTypeValue *left, DataTypeValue *right, int line) {
    if (strcmp(left->type, right->type) != 0) {
        printf("Error de tipo en la linea %d: %s (%s) no puede operar con %s (%s)\n", line, left->value, left->type, right->value, right->type);
    }
}

