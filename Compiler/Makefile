all: parser

parser.tab.c parser.tab.h:	parser.y
	bison -t -v -d parser.y

lex.yy.c: lexer.l parser.tab.h
	flex lexer.l

parser: lex.yy.c parser.tab.c parser.tab.h AST.h
	gcc -o parser parser.tab.c lex.yy.c
	./parser Semantic_analyzer_testfile.cmm

clean:
	rm -f parser lexer parser.tab.c lex.yy.c parser.tab.h parser.output Out.txt irOut.txt
	ls -l