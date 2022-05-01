/* Makes it so the program dose not use yywrap */
%option noyywrap

%{
    /* 
    Name: Erick Lagunas, Alita Rodriguez, Gaj Carson 
    Class: CST-405
    Date: TBD
    Prof: Isac Artzi
    Description: This program is a Lexical Analyzer for the C--/gcupl language
    */

    /* Include lines mostly for string.h, stdio.h is redundant */
    #include <stdio.h>
    #include <string.h>
    #include <stdlib.h>
    /* Note that parser.y must create parser.tab.h first, otherwise this file will fail to compile */
    #include "parser.tab.h"
    
    /* Defines the function yylex() */
    #define YY_DECL int yylex()

    extern int yyparse();

    /* Line counter declaration*/ 
    int lineCount = 1;

    int curlyCount = 0;
    int bracketCount = 0;
    int parenthesisCount = 0;

%}

/* Definition of a digit */
digit [0-9]
/* Definition of an ID. Identifiers with _ at the start are allowed in this implementation */
ID [a-zA-Z_][a-zA-Z0-9_]*

%x IN_COMMENT
%%

"int"   {
            // These are the tokens for the data types, if the rule matches the string litteral, the lexer code is executed. 
            // The procedure is pretty much the same for the rest of the tokens below.
            printf("%s | TYPE | %d \n",yytext,lineCount);
            
            // Block of code 
            yylval.string = strdup(yytext);
            return TYPE;
        }
"char"  {
            printf("%s | TYPE | %d \n",yytext,lineCount);
            yylval.string = strdup(yytext);
            return TYPE;
        }
"float" {
            printf("%s | TYPE | %d \n",yytext,lineCount);
            yylval.string = strdup(yytext);
            return TYPE;
        }
"bool"  {
            printf("%s | TYPE | %d \n",yytext,lineCount);
            yylval.string = strdup(yytext);
            return TYPE;
        }
"void"  {
            printf("%s | VOID | %d \n",yytext,lineCount);
            yylval.string = strdup(yytext);
            return VOID;
        }
"while" {
            printf("%s | WHILE | %d \n",yytext,lineCount);
            yylval.string = strdup(yytext);
            return WHILE;
        }
"write" {
            printf("%s | WRITE | %d \n",yytext,lineCount);
            yylval.string = strdup(yytext);
            return WRITE;
        }
"read"  {
            printf("%s | READ | %d \n",yytext,lineCount);
            yylval.string = strdup(yytext);
            return READ;
        }

"writeln"   {
                printf("%s | WRITELN | %d \n",yytext,lineCount);
                yylval.string = strdup(yytext);
                return WRITELN;
            }
"return"    {
                printf("%s | RETURN | %d \n",yytext,lineCount);
                yylval.string = strdup(yytext);
                return RETURN;
            }

"break" {
            printf("%s | BREAK | %d \n",yytext,lineCount);
            yylval.string = strdup(yytext);
            return BREAK;
        }
"continue" {
            printf("%s | CONTINUE | %d \n",yytext,lineCount);
            yylval.string = strdup(yytext);
            return CONTINUE;
        }
"if"    {
            printf("%s | IF | %d \n",yytext,lineCount);
            yylval.string = strdup(yytext);
            return IF;
        }
"else"  {
            printf("%s | ELSE | %d \n",yytext,lineCount);
            yylval.string = strdup(yytext);
            return ELSE;
        }
"false"  {
            printf("%s | ELSE | %d \n",yytext,lineCount);
            yylval.string = strdup(yytext);
            return FALSE;
        }
"true"  {
            printf("%s | ELSE | %d \n",yytext,lineCount);
            yylval.string = strdup(yytext);
            return TRUE;
        }

{ID}    {
            // This rule has a structure that is a bit different than before, the rule uses regex to detect ID 
            printf("%s | IDENTIFIER | %d \n",yytext,lineCount);
            yylval.string = strdup(yytext);
            return ID;
        }

\"(\\.|[^"\\])*\"   {    
                        // This is the rule for recognizing strings, this uses regex rules for the lexer to detect and tokenize comments.
                        printf("%s | STRING | %d \n",yytext,lineCount);
                        yylval.string = strdup(yytext);
                        return STRING;
                    }
{digit}+[a-zA-Z_][a-zA-Z0-9_]*  {
                                    printf("%s: INVALID IDENTIFIER ON LINE - %d -> IDs do not start with numbers! \n",yytext,lineCount);
                                    exit(0);
                                }

[1-9]{digit}+   {
                    printf("%s | Number | %d \n",yytext,lineCount);
                    yylval.number = atoi(strdup(yytext));
                    return NUMBER;
                }
{digit}         {
                    printf("%s | Number | %d \n",yytext,lineCount);
                    yylval.number = atoi(strdup(yytext));
                    return NUMBER;
                }

{digit}[.]{digit}+          {
                                printf("%s | Decimal | %d \n",yytext,lineCount);
                                yylval.string = strdup(yytext);
                                return FLOAT; 
                            } 
[1-9]{digit}+[.]{digit}+    {
                                printf("%s | Decimal | %d \n",yytext,lineCount);
                                yylval.string = strdup(yytext);
                                return FLOAT;
                            }

"/*"                {   
                        // Rule for recognizing the beginning of a block comment, everything after this token is to be shown as a comment.
                        yymore();
                        BEGIN(IN_COMMENT);
                    }           

<IN_COMMENT>"*/"    {
                        // Rule for recognizing the contents inside the comment block and closing with the */ tag.
                        BEGIN(INITIAL);
                        printf("%s | COMMENT | %d \n",yytext,lineCount);
                        yylval.string = strdup(yytext);
                        return COMMENT; 
                    }   


<IN_COMMENT>[^*\n]+   yymore(); // eat comment in chunks
<IN_COMMENT>"*"       yymore(); // eat the lone star
<IN_COMMENT>\n        { yymore(); yylineno++; } // Detects the end of a comment with a new line

"{"     {
            printf("%s | OPEN_CURLY | %d \n",yytext,lineCount);
            yylval.string = strdup(yytext);
            curlyCount++;
            return OPEN_CURLY;
        }
"}"     {
            printf("%s | CLOSED_CURLY | %d \n",yytext,lineCount);
            yylval.string = strdup(yytext);
            curlyCount++;
            return CLOSED_CURLY;
        }             
"("     {
            printf("%s | OPEN_PARENTHESIS | %d \n",yytext,lineCount);
            yylval.string = strdup(yytext);
            parenthesisCount++;
            return OPEN_PARENTHESIS;
        }
")"     {
            printf("%s | CLOSED_PARENTHESIS | %d \n",yytext,lineCount);
            yylval.string = strdup(yytext);
            parenthesisCount++;
            return CLOSED_PARENTHESIS;
        }
"["     {
            printf("%s | OPEN_BRACKET  | %d \n",yytext,lineCount);
            yylval.string = strdup(yytext);
            bracketCount++;
            return OPEN_BRACKET ;
        }
"]"     {
            printf("%s | CLOSED_BRACKET  | %d \n",yytext,lineCount);
            yylval.string = strdup(yytext);
            bracketCount++;
            return CLOSED_BRACKET;
        }

"=="    {
            printf("%s | RELATIONAL | %d \n",yytext,lineCount);
            yylval.string = strdup(yytext);
            return RELATIONAL; 
        }
"!="    {
            printf("%s | RELATIONAL | %d \n",yytext,lineCount);
            yylval.string = strdup(yytext);
            return RELATIONAL;
        }
"<="    {
            printf("%s | RELATIONAL | %d \n",yytext,lineCount);
            yylval.string = strdup(yytext);
            return RELATIONAL;
        }
">="    {
            printf("%s | RELATIONAL | %d \n",yytext,lineCount);
            yylval.string = strdup(yytext);
            return RELATIONAL;
        }
"&&"    {
            printf("%s | LOGICAL | %d \n",yytext,lineCount);
            yylval.string = strdup(yytext);
            return LOGICAL;
        }
"||"    {
            printf("%s | LOGICAL | %d \n",yytext,lineCount);
            yylval.string = strdup(yytext);
            return LOGICAL;
        }
[>]     {
            printf("%s | RELATIONAL | %d \n",yytext,lineCount);
            yylval.string = strdup(yytext);
            return RELATIONAL;
        }                       
[<]     {
            printf("%s | RELATIONAL | %d \n",yytext,lineCount);
            yylval.string = strdup(yytext);
            return RELATIONAL;
        }
":="    {
            //Rule for recognizing := operator, functions the same as a "="
            printf("%s | OPERATOR | %d \n",yytext,lineCount);
            yylval.string = strdup(yytext);
            return EQ;
        }
"="     {
            printf("%s | EQUALS | %d \n",yytext,lineCount);
            yylval.string = strdup(yytext);
            return EQ;
        } 
"-"     {   
            printf("%s | DASH | %d \n",yytext,lineCount);
            return yytext[0];
        }

"!"     {   
            printf("%s | OPERATOR | %d \n",yytext,lineCount);
            return yytext[0];
        }                                              
"/"     {
            printf("%s | OPERATOR | %d \n",yytext,lineCount);
            return yytext[0];
        }
"*"     {
            printf("%s | OPERATOR | %d \n",yytext,lineCount);
            return yytext[0];
        }
"+"     {
            printf("%s | OPERATOR | %d \n",yytext,lineCount);
            return yytext[0];
        }

";"     {
            printf("%s | SEMICOLON | %d \n",yytext,lineCount);
            yylval.string = strdup(yytext);
            return SEMICOLON;
        } 
","     { 
            printf("%s | COMMA | %d \n",yytext,lineCount);
            yylval.string = strdup(yytext);
            return COMMA;
        }

[ \t]+  
[\n\r]+ { lineCount++;} 

. {printf("%s | Not Recognized! | %d \n",yytext, lineCount);} 

%%
