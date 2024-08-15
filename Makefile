c2js_transpiler:
		bison -d -t yacc.y
		flex lex.l
		gcc -o traductor lex.yy.c yacc.tab.c -lfl
		./traductor < $(if $(FILE),$(FILE),prueba.c)

.PHONY: c2js_transpiler
