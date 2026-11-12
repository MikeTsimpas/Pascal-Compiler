all: lexer

syntax.tab.c syntax.tab.h: syntax.y
	bison -v -d syntax.y

lex.yy.c: lexer.l syntax.tab.h
	flex lexer.l

hashtbl.o: hashtbl.c hashtbl.h
	gcc -c hashtbl.c -o hashtbl.o

symtab.o: symtab.c symtab.h
	gcc -c symtab.c -o symtab.o

lexer: lex.yy.c syntax.tab.c syntax.tab.h hashtbl.o symtab.o
	gcc syntax.tab.c lex.yy.c hashtbl.o symtab.o -o a.out

clear:
	rm syntax.tab.c syntax.tab.h lex.yy.c hashtbl.o symtab.o syntax.output