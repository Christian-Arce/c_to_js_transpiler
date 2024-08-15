%{
#include "funciones.h"
#include "symbols.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yylex(void);
int yyerror(char *message);
extern int yylineno;

int argument_counter=0;
int expr_counter=0;
int dimension_counter=0;
int scope_number=0;
%}

%start program

%union {
    char *str;
    int num;
    float num_dec;
    char *data_type;
    char var_name[30];
}

%token<num>INTEGER
%token<num_dec>FLOAT_NUM
%token<str>INT CHAR FLOAT
%token<str>IDENTIFIER STRING CONST MLCOMMENT ILCOMMENT

%token<str> INC_OP DEC_OP INC_OP_LEFT INC_OP_RIGHT DEC_OP_LEFT DEC_OP_RIGHT GE_OP LE_OP EQ_OP NE_OP AND_OP OR_OP
%token<str>DECLARE DECLARE_ARRAY ARRAY
%token<str> FOR WHILE BREAK CONTINUE IF ELSE RETURN PRINTF STRLEN
%token <str> '-' '+' '>' '<' '*' '/' '}' '{' '(' ')' '[' ']' '=' ',' ':' '!' ';' '.' '%'

%type <str> program functionList function parameterList parameter typeName statementList statement exprList expr terminal array_expr array_exprList semicolon comment loop_statement if_statement declaration_unit translation_unit

%%

program:
        { printf("Comenzando a traducir a JavaScript\n"); create_output_file();}
        translation_unit
        { append_in_jsFile("main()");close_output_file(); print_symbolTable(); } // se agrega main() al final del programa js                                                             
       ;

translation_unit
        : functionList 
        | functionList translation_unit
        | declaration_unit translation_unit
        ;

functionList:
        function                                                                    
       |function functionList                                                      
       ;

function:
        typeName IDENTIFIER '(' {append_in_jsFile("function "); append_in_jsFile($2); append_in_jsFile("("); argument_counter=0;push(&scope_stack, ++scope_number);} parameterList ')' '{' {append_in_jsFile("){ \n"); put_symbol($2, $1, 0, argument_counter, 0, 0, yylineno);} statementList '}' {pop(&scope_stack);append_in_jsFile("\n} \n");}
        | typeName IDENTIFIER '(' ')' '{'{append_in_jsFile("function "); append_in_jsFile($2); append_in_jsFile("(){ \n");put_symbol($2, $1, 0, 0, 0, 0, yylineno); push(&scope_stack, ++scope_number);} statementList '}' {append_in_jsFile("\n} \n"); pop(&scope_stack);}                                      
       ;

parameterList:
        parameter                                                                  
       |parameter ','{append_in_jsFile(", ");} parameterList                                                
       ;

parameter:
        typeName IDENTIFIER {append_in_jsFile($2); ++argument_counter; put_symbol($2, $1, 0, 0, 0, 1, yylineno);}                                                          
       |typeName IDENTIFIER '[' ']'                                                
       ;

typeName:
        INT {$$ = strdup($1);}                                                                         
       |CHAR {$$ = strdup($1);}                                                                         
       |FLOAT {$$ = strdup($1);}                                                                    
       ;

statementList:
        statement                                                                   
       |statement statementList                                                     
       ;

statement:
        loop_statement                                                                                              
       |if_statement                                
       |RETURN {append_in_jsFile("return ");}expr semicolon {append_in_jsFile("\n");}                                                         
       |PRINTF '(' {append_in_jsFile("console.log(");} exprList ')' semicolon  {append_in_jsFile(") \n");}                                               
       |IDENTIFIER '(' {append_in_jsFile($1); append_in_jsFile("("); expr_counter=0;} exprList ')' {append_in_jsFile(")");} semicolon {append_in_jsFile("\n"); check_arguments($1, expr_counter, yylineno);} // llamada a funcion                                            
       |IDENTIFIER '=' {append_in_jsFile($1);append_in_jsFile(" = ");} expr semicolon {append_in_jsFile("\n"); }                                                     
       |IDENTIFIER '[' {append_in_jsFile($1); append_in_jsFile("[");} expr ']' '=' {append_in_jsFile("]"); append_in_jsFile("=");} expr semicolon {append_in_jsFile("\n");}                                    
       |declaration_unit                              
       |inc_operadores expr semicolon {append_in_jsFile("\n");}                                                                                                             
       |expr inc_operadores semicolon {append_in_jsFile("\n");}   
       |comment                                   
       ;

loop_statement
        :WHILE {append_in_jsFile("while(");} '(' expr ')' '{' {append_in_jsFile("){ \n"); push(&scope_stack, ++scope_number);} statementList '}' {append_in_jsFile("\n} \n");pop(&scope_stack);}
        ;

if_statement
        :IF {append_in_jsFile("if(");} '(' expr ')' {append_in_jsFile("){ \n");push(&scope_stack, ++scope_number);} '{' statementList '}' {append_in_jsFile("\n} \n");pop(&scope_stack);}  elseStatement
        ;
inc_operadores:
        INC_OP {append_in_jsFile("++");}
        | DEC_OP {append_in_jsFile("--");}
        ;
elseStatement:
        ELSE '{' {append_in_jsFile("else{ \n");push(&scope_stack, ++scope_number);}  statementList '}' {append_in_jsFile("\n} \n");pop(&scope_stack);} 
        |
        ;
declaration_unit
        :typeName IDENTIFIER '=' {append_in_jsFile("let "); append_in_jsFile($2);append_in_jsFile(" = ");} expr semicolon  {append_in_jsFile("\n"); put_symbol($2, $1, 0, 0, 0, 1, yylineno);} // definicion de variable                          
       |CONST typeName IDENTIFIER '=' {append_in_jsFile("const "); append_in_jsFile($3);append_in_jsFile(" = ");} expr semicolon  {append_in_jsFile("\n"); put_symbol($3, $2, 1, 0, 0, 1, yylineno);} //definicion de constante
       |typeName IDENTIFIER '[' ']' '=' {append_in_jsFile("let "); append_in_jsFile($2);append_in_jsFile(" = ");} expr semicolon {append_in_jsFile("\n");} // strings                             
       |typeName IDENTIFIER '[' ']' '=' '{' {append_in_jsFile("let "); append_in_jsFile($2);append_in_jsFile(" = [");} exprList '}' semicolon { append_in_jsFile("]\n"); put_symbol($2, $1, 0, 0, 1, 1, yylineno);} // arrays 
       |typeName IDENTIFIER '[' INTEGER ']' '[' INTEGER ']' '=' '{' '{' {append_in_jsFile("let "); append_in_jsFile($2);append_in_jsFile(" = [[");} exprList '}' ',' '{' {append_in_jsFile("], [");} exprList '}' '}' semicolon { append_in_jsFile("]]\n"); put_symbol($2, $1, 0, 0, 2, 1, yylineno);} // arrays     
       |typeName IDENTIFIER '[' INTEGER ']' semicolon {append_in_jsFile("let "); append_in_jsFile($2);append_in_jsFile("= new Array("); char num_str[20]; snprintf(num_str, sizeof(num_str), "%d", $4);append_in_jsFile(strdup(num_str));append_in_jsFile(") \n"); put_symbol($2, $1, 0, 0, 1, 1, yylineno);}                               
       |typeName IDENTIFIER '[' INTEGER ']' '=' '{' {append_in_jsFile("let "); append_in_jsFile($2);append_in_jsFile("= [");}  exprList '}' semicolon {append_in_jsFile("]\n"); put_symbol($2, $1, 0, 0, 1, 1, yylineno);}                         
       |typeName IDENTIFIER semicolon {append_in_jsFile("let "); append_in_jsFile($2);append_in_jsFile("\n");put_symbol($2, $1, 0, 0, 0, 1, yylineno);}
       ;
exprList:
        expr {++expr_counter;}                                  
       |expr ',' {append_in_jsFile(", "); ++expr_counter;} exprList                                                         
       ;

expr:
        terminal  {append_in_jsFile($1);}                                       
       |'-' expr                                   
       |STRLEN '(' IDENTIFIER ')'                                    
       |IDENTIFIER '(' {append_in_jsFile($1); append_in_jsFile("("); } exprList ')' {append_in_jsFile(")");}                                       
       |IDENTIFIER {append_in_jsFile($1); dimension_counter=0;} array_exprList {check_dimension($1, dimension_counter, yylineno);} //llamada a un array                     
       |expr operator expr {DataTypeValue *left_type = get_data_type($1); DataTypeValue *right_type = get_data_type($3); check_type(left_type, right_type, yylineno);}                                                                                                      
       |'!' {append_in_jsFile("!");} expr                                                                  
       |'('{append_in_jsFile("(");} expr ')' {append_in_jsFile(")\n");}                                                                                                                             
       ;

array_exprList
        : array_expr {++dimension_counter;}
        | array_expr {++dimension_counter;} array_exprList
        ;

array_expr
        : '[' {append_in_jsFile("["); } expr ']' {append_in_jsFile("]");}
        ;

operator:
        '+' {append_in_jsFile("+");}
        | '-' {append_in_jsFile("-");}
        | '*' {append_in_jsFile("*");}
        | '/' {append_in_jsFile("/");}
        | '<' {append_in_jsFile("<");}
        | '>' {append_in_jsFile(">");}
        | EQ_OP {append_in_jsFile("==");}
        | NE_OP {append_in_jsFile("!=");}
        | OR_OP {append_in_jsFile("||");}
        | AND_OP {append_in_jsFile("&&");}
        | LE_OP {append_in_jsFile("<=");}
        | GE_OP {append_in_jsFile(">=");}
        ;

terminal:
        INTEGER {char num_str[20]; snprintf(num_str, sizeof(num_str), "%d", $1); $$ = strdup(num_str);}                                      
       |STRING   {$$ = strdup($1);}                                        
       |IDENTIFIER {$$ = strdup($1);}                                   
       |FLOAT_NUM {char num_str[20]; snprintf(num_str, sizeof(num_str), "%f", $1); $$ = strdup(num_str);}

semicolon:
        ';'
        | {printf("Error de punto y coma en la linea %d: falta punto y coma\n", yylineno);}

comment     
        : ILCOMMENT     { append_in_jsFile( yylval.var_name); append_in_jsFile("\n");}
        | MLCOMMENT     { append_in_jsFile(yylval.var_name); append_in_jsFile("\n");} 

%%

int main(int argc, char *argv[]) {
        scope_stack = createScope(scope_number);
        return yyparse();
}

int yyerror(char *message) {
    printf("Error: %s en la línea %d\n", message, yylineno);
    return -1;
}
