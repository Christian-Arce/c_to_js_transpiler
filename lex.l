%{
#include <stdio.h>
#include "yacc.tab.h"
%}
%option yylineno
L	        ([_A-Za-z])
D		    ([0-9])
integer		({D}+)
identifier	({L}({L}|{D})*)
blank   	([ \f\r\n\t\v ])
string      ('(\\.|[^\\'])+'|\"(\\.|[^\\"])*\")

%%
#include([^\n])*                    {}
 /* multiline comments in C like /* int var1; \n printf("f"); *\/ */
"/\*"(.|\n)*"\*/"       {strcpy(yylval.var_name, yytext); return MLCOMMENT;} 

  /* Single line comments in C e.g: '//', '//  ', '// lorem impsu2' */
"//"(.)*                {strcpy(yylval.var_name, yytext); return ILCOMMENT;} 
"for"                               {return(FOR);}
"while"                             {return(WHILE);}
"break"                             {return(BREAK);}
"continue"                          {return(CONTINUE);}
"if"                                {return(IF);}
"else"                              {return(ELSE);}

"int"                               {yylval.data_type=strdup("int"); return(INT);}
"char"                              {yylval.data_type=strdup("char"); return(CHAR);}
"float"                            {yylval.data_type=strdup("float"); return(FLOAT);}
"const"								{return(CONST);}

"return"		                    {return(RETURN);}
"printf"                            {return(PRINTF);}
"strlen"                            {return(STRLEN);}

{identifier}                        {yylval.str=strdup(yytext);return(IDENTIFIER);}
{string}                            {yylval.str=strdup(yytext);return(STRING);}
{integer}                           {yylval.num=atoi(yytext);return(INTEGER);}

{D}*"."{D}+                         { yylval.num_dec = atof(yytext); return(FLOAT_NUM);}
{D}+"."{D}*                         { yylval.num_dec = atof(yytext); return(FLOAT_NUM);}

">="                                {return(GE_OP);}
"<="			                    {return(LE_OP);}
"=="			                    {return(EQ_OP);}
"!="			                    {return(NE_OP);}
"&&"			                    {return(AND_OP);}
"||"			                    {return(OR_OP);}
"++"			                    {return(INC_OP);}
"--"			                    {return(DEC_OP);}

"-"                                 {return('-');}
"+"                                 {return('+');}
"*"                                 {return('*');}
"/"                                 {return('/');}
"%"                                 {return('%');}
"<"                                 {return('<');}
"."                                 {return('.');}
">"                                 {return('>');}
","                                 {return(',');}
":"                                 {return(':');}
";"                                 {return(';');}
"="                                 {return('=');}
"("                                 {return('(');}
")"                                 {return(')');}
"{"     		                    {return('{');}
"}"      		                    {return('}');}
"["      		                    {return('[');}
"]"      		                    {return(']');}
"!"                                 {return('!');}
{blank}		                        {}

.			                        {}

%%

int yywrap()
{
	return 1;
}