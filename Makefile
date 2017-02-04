
scanner.tab.c scanner.tab.h: scanner.y
	bison -d scanner.y

lex.yy.c: scanner.l scanner.tab.h
	flex scanner.l

scanner: lex.yy.c scanner.tab.c scanner.tab.h
	g++ scanner.tab.c lex.yy.c -lfl -o parser

