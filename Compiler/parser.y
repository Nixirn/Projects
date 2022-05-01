%{

    /* 
    Name: Erick Lagunas, Alita Rodriguez, Gaj Carson 
    Class: CST-405
    Date: 10 / 31 / 21
    Prof: Isac Artzi
    Description: This program is a Lexical Analyzer for the C--/gcupl language
    */ 

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "AST.h"
#include "symbolTable.h"
#include "scopeStack.h"
#include "semanticUtils.h"


//File management variables:
extern int yylex();
extern FILE *yyin, *yyout;
FILE * irOut;

//Count management variables:
extern int lineCount;
extern int parenthesisCount;
extern int bracketCount;
extern int curlyCount;
extern char ** tempArr;
extern char ** FuncArr;
extern char ** ReturnArr;

int errorCounter = 0; //Implement an error counter so that the parser can instead ignore errors and complete parsing
//Note that in this implementation the parser will not exit when an error is detected. In future implementations, this will change

//Check the number of parameters to semantically check function calls:
int parameterCount = 0;
int dataIndex = 0;
int globalDataIndex = 0;
int arrayDataIndex = 0;
int tagCount = 0;

//Management of integers and floats as strings:
char inttoStr[50];

//Operation & type management
char storeType[30];
char storeDupe[30];

char ops[10] = "/+-*";
char catString[100];
char mipsLine[200];

//Detection of return statements when type checking:
bool usingReturn = false;

//Stack management
struct Stack* stack = NULL;
symbol * sym = NULL;
data * dataOut = NULL;
data * globalDataOut = NULL;
data * arrayDataOut = NULL;

// Output errors
void yyerror(const char* s);
%}

//Declarations of items used throughout the parser:
%union {
    struct AST * ast;
	int number;
	char character;
	char* string;
    double floating;
}

/* Define all of the tokens that the lexer could return, making sure to use the same names and spelling */
%token <string> TYPE STRING ID
%token <char> SEMICOLON
%token <number> NUMBER
%token <string> FLOAT
%token WRITE READ WRITELN
%token RETURN BREAK IF WHILE
%token CONTINUE ELSE VOID TRUE FALSE 
%token <character> OPEN_CURLY CLOSED_CURLY
%token <character> OPEN_PARENTHESIS CLOSED_PARENTHESIS
%token <character> OPEN_BRACKET CLOSED_BRACKET
%token <string> LOGICAL RELATIONAL COMMENT
%token <string> EQ
%token <character> COMMA

//Error handling:
%define parse.error verbose

//Printers that make it easier to print certain tokens:
%printer { fprintf(yyoutput, "%s", $$); } ID;
%printer { fprintf(yyoutput, "%d", $$); } NUMBER;

//Precedence for operators:
%right EQ
%left '+' '-'
%left '*' '/'
%left op
%left OPEN_PARENTHESIS 

//Nonterminal type declaration:
%type <ast> Program CallList Call DeclList Decl FuncTail ParamDecl ParamDeclList IfTail Array Block StmtList Stmt Expr ExprList ExprListTail Primary

%start Program

%%
     
Program:        DeclList CallList                                               {
                                                                                    //Outputs for completing parsing section:
                                                                                    fprintf(yyout,"---------- SUCCESS! ----------\n");
                                                                                    fprintf(yyout,"CURLY: %d, PARENTHESIS: %d, BRAKETS: %d\n", curlyCount, parenthesisCount, bracketCount);
                                                                                    printf("---------- AST TREE ----------\n\n");

                                                                                    //Scope management: Since the parser reads program last, the last thing to be popped shoul be the global scope
                                                                                    char * out = pop(stack);
                                                                                    printf("\nScope Popped!: %s <-----\n", out);
                                                                                    //The stack should be empty at the end of parsing. 

                                                                                    $$ = $1; //Porpogate the entire tree
                                                                                }
;

CallList:                                                                       {  
                                                                                    fprintf(yyout,"---EPSILON ( STMTLIST ) | (%d)---\n",lineCount); //Grammar rule output
                                                                                    $$ = NULL; //Terminal node
                                                                                }
            |   Call CallList                                                   {
                                                                                    fprintf(yyout,"---CALL CALLLIST | (%d)---\n",lineCount); //Grammar rule output
                                                                                    $$ = newNode("CallList", $1, $2); //AST configuration
                                                                                }
;

Call:       ID OPEN_PARENTHESIS CLOSED_PARENTHESIS SEMICOLON                    {
                                                                                    fprintf(yyout,"-FUNCTION CALL-\n"); //Grammar rule output
                                                                                    char * terminalName = strcat($1, "();"); //Function call string management
                                                                                    $$ = terminalNode(terminalName); //Terminal node management in AST
                                                                                    fprintf(irOut,"jal %s \n", $1); //IR code printed to text file for jump and link for function call
                                                                                }
;

DeclList:                                                                       { 
                                                                                    fprintf(yyout,"---EPSILON ( DECLLIST ) | (%d)---\n",lineCount); //Grammar rule output
                                                                                    $$ = NULL; //Node management in AST
                                                                                }               
                | Decl DeclList                                                 { 
                                                                                    fprintf(yyout,"---DECL DECLIST | (%d)---\n",lineCount); //Grammar rule output
                                                                                    $$ = newNode("DeclList", $1, $2); //AST node configuration
                                                                                }
                | StmtList DeclList                                             { 
                                                                                    fprintf(yyout,"---Stmt DECLIST | (%d)---\n",lineCount); //Grammar rule output
                                                                                    $$ = newNode("StmtList", $1, $2); //AST node configuration
                                                                                }
;

Decl:           TYPE ID SEMICOLON                                               {   
                                                                                    fprintf(yyout,"-VAR DECL- %d\n",lineCount); //Grammar rule output
                                                                                    $$ = newNode($1, terminalNode($2), terminalNode("Semicolon")); //AST node management
                                                                                    
                                                                                    symbol_table_installsym($2, "varDecl", $1, -1, peek(stack)); //A new symbol needs to be added to the symbol table with the associated values
                                                                                    //Note that contents is modified later on

                                                                                    installReg($2, peek(stack), returnTempVal());
                                                                                }
                | TYPE Array    {
                                    strcpy(storeType,$1); //Storage of types for type checking
                                } 
                                
                                SEMICOLON                                       {
                                                                                    fprintf(yyout,"-ARRAY DECL-\n"); //Grammar rule output
                                                                                    $$ = newNode("Array", terminalNode($1), $2); //AST node management
                                                                                }
                | TYPE ID   {
                                symbol_table_installsym($2, "funcDecl", $1, -1, peek(stack)); //A new symbol needs to be added to the symbol table
                                push(stack, $2); //Note that the symbol is added before the new scope is pushed to the stack since the function is considered to be in the global scope
                                parameterCount = 0; //Set parameter count to 0 at the beginning of a function declaration
                                fprintf(irOut,"%s: \n", $2); //IR code for storage of function declaration
                            } 

                            FuncTail                                            {
                                                                                    fprintf(yyout,"-FUNC DECL (%s)-\n", $2); //Grammar rule output
                                                                                    $$ = newNode($1, terminalNode($2), $4); //AST node management
                                                                                    //Semantic Check: Functions of a declared type must have a return statement, regardless of the return statement's type
                                                                                    if(!usingReturn){
                                                                                        printf("##### SEMANTIC ERROR: Function (%s) of type (%s) dose not have a return stmt\n", $2, $1);
                                                                                        errorCounter++; //An error is detected, but parsing will continue since errors will be temporarily ignored
                                                                                    }
                                                                                    usingReturn = false; //Reset return boolean
                                                                                    fprintf(irOut,"\tjr $ra\n"); //IR code to jump to the address of $ra, copies contents of function
                                                                                }
                | VOID ID   {
                                symbol_table_installsym($2, "funcDecl", "void", -1, peek(stack)); //Add the new symbol to the symbol table for a void function
                                push(stack, $2); //Modify the scope stack to be within the new function's scope
                                parameterCount = 0; //Set parameter count to 0 at the beginning of a function call
                                fprintf(irOut,"%s: \n", $2); //IR code for storage of function declaration
                            } 
                            
                            FuncTail                                            {
                                                                                    fprintf(yyout,"-FUNC DECL (%s)-\n", $2); //Grammar rule output
                                                                                    $$ = newNode("VOID", terminalNode($2), $4); //AST node management

                                                                                    if(strcmp(peek(stack), "main") == 0){
                                                                                        fprintf(irOut,"\tli $v0, 10\n\tsyscall\n");
                                                                                    } else {
                                                                                        fprintf(irOut,"\tjr $ra\n"); //IR code to jump tot he address of $ra, copies contents of function
                                                                                    }

                                                                                    char * out = pop(stack); //It is now time to change the scope back to the previous one on the stack
                                                                                    printf("Scope Popped!: %s <-----\n", out); //Notify the scope has been changed in the output
                                                                                }
                | COMMENT                                                       {   
                                                                                    fprintf(yyout, "- DECL COMMENT | (%d)-\n", lineCount); //Grammar rule output
                                                                                    $$ = terminalNode("COMMENT"); //AST node management
                                                                                }
;

FuncTail:       OPEN_PARENTHESIS    {  
                                        sym = findSymInRecentScope(peek(stack), stack); //Mid rule to find the function in symbol table to be modified
                                        installLength(sym, parameterCount); //Modify the length to be the number of parameters
                                    }
                                    
                                    CLOSED_PARENTHESIS Block                    {
                                                                                    fprintf(yyout,"-FUNC W/O PARAMS | (%d)-\n",lineCount);  //Grammar rule output
                                                                                    $$ = $4; //Node management
                                                                                    
                                                                                }
                | OPEN_PARENTHESIS  {  
                                        sym = findSymInRecentScope(peek(stack), stack); //Find the function in the symbol table
                                        installLength(sym, parameterCount); //Modify the symbol table to account for the number of parameters in the function declaration
                                    }
                                    
                                    CLOSED_PARENTHESIS SEMICOLON                {
                                                                                    fprintf(yyout,"-FUNCTION CALL-\n"); //Grammar rule output
                                                                                    $$ = terminalNode("();"); //AST node management

                                                                                    pop(stack); //Remove the current scope since it is exited with an empty function
                                                                                }
                | OPEN_PARENTHESIS ParamDeclList    {  
                                                        sym = findSymInRecentScope(peek(stack), stack); //Find the function in the symbol table with correct scope
                                                        installLength(sym, parameterCount); //Modify the number of parameters for the function in the symbol table
                                                    } 
                                                    
                                                    CLOSED_PARENTHESIS Block    {   
                                                                                    fprintf(yyout,"-FUNC DECL TAIL| (%d)-\n",lineCount); //Grammar rule output
                                                                                    $$ = newNode("ParamFunction", $2, $5); //AST node management
                                                                                    char * out = pop(stack); //Scope management
                                                                                    printf("Scope Popped!: %s <-----\n", out); //Scope output
                                                                                }
;

ParamDeclList:  ParamDecl { parameterCount++; /*Count the number of parameters */ }                                                       {
                                                                                    fprintf(yyout,"---PARAMDECL | (%d)---\n",lineCount); //Grammar rule output
                                                                                    $$ = $1; //Node management
                                                                                }
                | ParamDecl { parameterCount++; /* count the number of parameters */ } COMMA ParamDeclList                                 {
                                                                                    fprintf(yyout,"---PARAMDECL COMMA LIST | (%d)---\n",lineCount); //Grammar rule output
                                                                                    $$ = newNode(",", $1, $4); //Node management
                                                                                }
;

ParamDecl:      TYPE ID                                                         {
                                                                                    fprintf(yyout, "-PARAMETER DECL (%s)-\n", $1); //Grammar rule output
                                                                                    $$ = newNode("Parameter", terminalNode($1), terminalNode($2)); //Node management
                                                                                    // Needs to be added into the symbol table:

                                                                                    symbol_table_installsym($2, "varDecl", $1, -1, peek(stack)); //When a parameters is declared, it becomes a symbol within the scope of the function it belongs to
                                                                                    
                                                                                    if (strcmp($1,'char')== 0)
                                                                                    {
                                                                                        fprintf(irOut,"li %s,'%s'", returnFuncVal(),$2);
                                                                                    } 
                                                                                    else
                                                                                    {
                                                                                        fprintf(irOut,"li %s,%s", returnFuncVal(),$2);
                                                                                    }           
                                                                                                                 
                                                                                }
                | TYPE ID OPEN_BRACKET CLOSED_BRACKET                           {  
                                                                                    fprintf(yyout, "-EMPTY ARRAY PARAMETER DECL (%s)-\n", $1); //Grammar rule output
                                                                                    $$ = newNode("EmptyArrayParam", terminalNode($1), terminalNode($2)); //Node management
                                                                                    symbol_table_installsym($2, "arrayDecl", $1, -1, peek(stack)); //Symbol table management
                                                                                }
                | TYPE Array                                                    {
                                                                                    fprintf(yyout, "-ARRAY PARAMETER DECL (%s)-\n", $1); //Grammar rule output
                                                                                    $$ = newNode("ArrayParam", terminalNode($1), $2); //Node management

                                                                                    strcpy(storeType,$1); //Type checking management
                                                                                }
;

Array:  ID OPEN_BRACKET NUMBER CLOSED_BRACKET                                   {
                                                                                    fprintf(yyout, "-ARRAY TAIL (%s)(%d)-\n", $1, $3); //Grammar rule output
                                                                                    sprintf(inttoStr, "%d", $3); //Integer string management
                                                                                    $$ = newNode("ArrayTail", terminalNode($1), terminalNode(inttoStr)); //Node management
                                                                                    symbol_table_installsym($1, "arrayDecl", storeType, $3, peek(stack)); //Add the symbol to the symbol table

                                                                                    //SEMANTIC CHECK: Array assignment must actually be declared as an array
                                                                                    if(checkKind($1, stack) != 1) {
                                                                                        printf("##### SEMANTIC ERROR: %s is not an array! %s\n", $1, peek(stack)); //Output error
                                                                                        errorCounter++; //Increment errors
                                                                                    }

                                                                                    char * temp = "";
                                                                                    sprintf(temp,"%d",$3);
                                                                                    arrayDataOut->dataStrings[arrayDataIndex] = $1;
                                                                                    arrayDataOut->vals[arrayDataIndex] = temp;
                                                                                    arrayDataIndex++;

                                                                                }
        | ID OPEN_BRACKET ID CLOSED_BRACKET                                     {
                                                                                    fprintf(yyout, "-ARRAY TAIL (%s)(%s)-\n", $1, $3); //Grammar rule output
                                                                                    $$ = newNode("ArrayTail", terminalNode($1), terminalNode($3));  //Node management

                                                                                    int arrayLen = 0;

                                                                                    // get contents from symbol table
                                                                                    sym = findSymInRecentScope($3, stack);
                                                                                    if(sym->contents[0] == NULL) {
                                                                                        printf("##### SEMANTIC ERROR: ID (%s) used as length not defined! in (%s)\n", $3, peek(stack));
                                                                                        errorCounter++; //increment
                                                                                    } else {
                                                                                        // convert contents 0 to int and set arrayLen
                                                                                        if(strcmp(sym->type, "int") != 0) {
                                                                                            printf("##### SEMANTIC ERROR: ID (%s) used as length not int! in (%s)\n", $3, peek(stack));
                                                                                            errorCounter++; //increment
                                                                                        }
                                                                                        arrayLen = atoi(sym->contents[0]);
                                                                                    }

                                                                                    symbol_table_installsym($1, "arrayDecl", storeType, arrayLen, peek(stack)); //Store members of the array in the symbol table
                                                                                    

                                                                                    //SEMANTIC CHECK: Array indices must be an integer
                                                                                    char * check = getType($3, peek(stack));
                                                                                    if(strcmp(check,"int") != 0) {
                                                                                        printf("##### SEMANTIC ERROR: Array index for %s is not an int! in %s\n", $1, peek(stack));
                                                                                        errorCounter++; //increment
                                                                                    }
                                                                                    //The identifier used in the context of an array must also be declared as an array
                                                                                    if(checkKind($1, stack) != 1) {
                                                                                        printf("##### SEMANTIC ERROR: %s is not an array! in %s\n", $1, peek(stack));
                                                                                        errorCounter++; //increment
                                                                                    }             
                                                                                }
;

Block:          OPEN_CURLY CLOSED_CURLY                                         {
                                                                                    fprintf(yyout, "-EMPTY BLOCK-\n"); //Grammar output
                                                                                    $$ = terminalNode("{}"); //AST node management
                                                                                }
                | OPEN_CURLY DeclList StmtList CLOSED_CURLY                     {
                                                                                    fprintf(yyout, "-BLOCK-\n"); //Grammar output
                                                                                    $$ = newNode("Block", $2, $3); //AST node management
                                                                                }
;

StmtList:                                                                       {
                                                                                    fprintf(yyout,"---EPSILON ( STMTLIST ) | (%d)---\n",lineCount); //Grammar output
                                                                                    $$ = NULL; //AST node management
                                                                                }
            | Stmt StmtList                                                     {
                                                                                    fprintf(yyout,"---STMT STMTLIST | (%d)---\n",lineCount); //Grammar output
                                                                                    $$ = newNode("StmtList", $1, $2); //AST node management
                                                                                }
;

Stmt:   SEMICOLON                                                               {
                                                                                    fprintf(yyout, "-STATEMENT-\n"); //Grammar output
                                                                                    $$ = terminalNode("Semicolon"); //AST node management
                                                                                }
        | COMMENT                                                               {   
                                                                                    fprintf(yyout, "-STMT COMMENT | (%d)-\n", lineCount); //Grammar output
                                                                                    $$ = terminalNode("COMMENT");  //AST node management
                                                                                }
        | Expr SEMICOLON                                                        {  
                                                                                    fprintf(yyout, "-EXPR COMMA | (%d)-\n",lineCount);  //Grammar output
                                                                                    $$ = newLeftNode("Expr", $1); //AST node management
                                                                                }
        | RETURN Expr SEMICOLON                                                 {
                                                                                    fprintf(yyout, "-RETURN STATEMENT-\n"); //Grammar output
                                                                                    $$ = newLeftNode("Return", $2); //AST node management


                                                                                    usingReturn = true; //Boolean, a return statement exists in the function

                                                                                    int functionIndex = searchConditionals(stack);

                                                                                    char * funcType = getType(stack->array[functionIndex], stack->array[functionIndex - 1]); //Retrieve the typoe of the function being used
                                                                                    printf("Type retrieved : %s\n", funcType); //Print debugging
                                                                                    //SEMANTIC ERROR: A function of type void cannot be using a return statement because then it would be useless
                                                                                    if (strcmp(funcType, "Void") == 0){
                                                                                        printf("##### SEMANTIC ERROR: function of type VOID does not have a return value.");
                                                                                        errorCounter++; //Increment
                                                                                    }
                                                                                    
                                                                                    //SEMANTIC CHECK: Type checking the return statement
                                                                                    char * nodeStr1;
                                                                                    char * nodeStr2;
                                                                                    char * remainder = strstr(ops, $2->nodeType);
                                                                                    bool succeeded = false; //Initialize debugging variable for functions called

                                                                                    if (remainder == NULL){
                                                                                        printf("Check Return: (%s, %s)----------\n", $2->nodeType, peek(stack)); //Print debugging

                                                                                        if(checkForTerminal($2) != 1) {
                                                                                            nodeStr1 = checkExperNodeType($2);
                                                                                        } else {
                                                                                            nodeStr1 = $2->nodeType;
                                                                                        } 

                                                                                        succeeded = typeCheck(peek(stack), nodeStr1, stack); //Type check is either true or false
                                                                                        if(!succeeded) {
                                                                                            printf("##### SEMANTIC ERROR: Return statment in %s has incorrect return type! \n", peek(stack));
                                                                                            errorCounter++;
                                                                                        } 
                                                                                    }

                                                                                    //Symbol Table Management:

                                                                                    
                                                                                    sym = findSymInRecentScope(stack->array[functionIndex], stack); //The function symbol
                                                                                    

                                                                                    //Special conditions when nodeType of expression is not a clear value:
                                                                                    if (strcmp($2->nodeType, "Array") == 0)
                                                                                    {
                                                                                        symbol * thisSym = findSymInRecentScope($2->left->nodeType, stack);
                                                                                        char * myContents = retrieveContents(thisSym, atoi($2->right->nodeType));
                                                                                        installContents(sym, myContents, 0);
                                                                                    }
                                                                                    else
                                                                                    {
                                                                                        installContents(sym, $2->nodeType, 0);
                                                                                    }
                                                                                }
        | READ ID SEMICOLON                                                     {
                                                                                    fprintf(yyout, "-READ STATEMENT-\n"); //Grammar output
                                                                                    $$ = newLeftNode("Read", terminalNode($2)); //Node management
                                                                                }
        | WRITE Expr SEMICOLON                                                  {   
                                                                                    fprintf(yyout, "-WRITE STATEMENT-\n"); //Grammar output
                                                                                    $$ = newLeftNode("Write", $2); //Node management

                                                                                    char * ty = NULL;
                                                                                    char * symboleRegister = NULL;
                                                                                    if(strcmp($2->type, "") == 0) {
                                                                                        sym = findSymInRecentScope($2->nodeType, stack);
                                                                                        ty = sym->type;
                                                                                        symboleRegister = sym->reg;
                                                                                    } else {
                                                                                        ty = $2->type;
                                                                                    }

                                                                                    //Intermediate Code:
                                                                                    if(strcmp(ty, "int") == 0) {
                                                                                        fprintf(irOut,"\tmove $a0, %s\n\tli $v0, 1\n\tsyscall\n", symboleRegister); //Load word to registers when called to write, special case for arrays
                                                                                    } else {
                                                                                        fprintf(irOut,"\tla $a0, %s\n\tli $v0, 4\n\tsyscall\n", $2->nodeType); //Load word to registers when called to write
                                                                                    }


                                                                                }
        | WRITELN SEMICOLON                                                     {   
                                                                                    fprintf(yyout, "-WRITELN STATEMENT-\n"); //Grammar output
                                                                                    $$ = terminalNode("WriteLn"); //Node management
                                                                                }
        | WRITELN ExprList SEMICOLON                                            {   
                                                                                    fprintf(yyout, "-WRITELN STATEMENT-\n"); //Grammar output
                                                                                    $$ = newLeftNode("WriteLn", $2); //Node management
                                                                                    printf("##### SEMANTIC ERROR: writln dose not print strings! only prints new lines!\n");
                                                                                    //SEMANTIC ERROR HANDLING: WriteLn cannot take any arguments. 
                                                                                    errorCounter++;
                                                                                }
        | BREAK SEMICOLON                                                       {
                                                                                    fprintf(yyout, "-BREAK STATEMENT-\n"); //Grammar output
                                                                                    $$ = terminalNode("Break"); //Node management
                                                                                    //SEMANTIC CHECK: Break can only be used within a loop
                                                                                    if(strcmp(peek(stack), "While") != 0) {
                                                                                        printf("##### SEMANTIC ERROR: Break used outside of loop! in %s\n", peek(stack));
                                                                                    }
                                                                                }
        | CONTINUE SEMICOLON                                                    {
                                                                                    fprintf(yyout, "-CONTINUE STATEMENT-\n"); //Grammar output
                                                                                    $$ = terminalNode("Continue"); //AST node management
                                                                                    //SEMANTIC CHECK: Continue can only be used within a loop
                                                                                    if(strcmp(peek(stack), "While") != 0) {
                                                                                        printf("##### SEMANTIC ERROR: Continue used outside of loop! in %s\n", peek(stack));
                                                                                    }
                                                                                }
        | IF    {
                    push(stack, "IF"); //Scope management
                    tagCount++;
                }  
                
                OPEN_PARENTHESIS Expr CLOSED_PARENTHESIS IfTail               {
                                                                                    //Note that grammar has since been changed to include an IF tail since precedence and mid rules were not cooperating
                                                                                    fprintf(yyout, "-IF STATEMENT-\n"); //Grammar output
                                                                                    $$ = newNode("If", $4, $6); //Node management

                                                                                    char * out = pop(stack); //Scope management
                                                                                    printf("Scope Popped!: %s <-----\n", out);
                                                                                    //SEMANTIC CHECK:
                                                                                    // Checks if the type of the expression node is not bool to return an error
                                                                                    if(strcmp($4->type, "bool") != 0) {
                                                                                        printf("##### SEMANTIC ERROR: Condition in if is not boolean! in %s", peekUnder(stack));
                                                                                        errorCounter++;
                                                                                    } else {
                                                                                        fprintf(irOut,"ENDIF%d: \n", tagCount); //IR code for ELSE statement
                                                                                        tagCount--;
                                                                                    }
                                                                                }
        | WHILE OPEN_PARENTHESIS    {
                                        push(stack, "WHILE"); //Scope management
                                        tagCount++;
                                        fprintf(irOut,"WHILE%d:\n", tagCount); //Conditional while IR code written
                                    }  

                                    Expr CLOSED_PARENTHESIS Block               {
                                                                                    fprintf(yyout, "-WHILE STATEMENT-\n"); //Grammar output
                                                                                    $$ = newNode("While", $4, $6); //Node management

                                                                                    char * out = pop(stack); //Scope management
                                                                                    printf("Scope Popped!: %s <-----\n", out);
                                                                                    //SEMANTIC CHECK:
                                                                                    // Checks if the type of the expression node is not bool to return an error
                                                                                    if(strcmp($4->type, "bool") != 0) {
                                                                                        printf("##### SEMANTIC ERROR: Condition in while is not boolean! in %s", peekUnder(stack));
                                                                                        errorCounter++;
                                                                                    } else {
                                                                                        //If no errors print ircode
                                                                                        fprintf(irOut,"\n\tj WHILE%d\nEXIT%d: \n",tagCount,tagCount); //Jump to the contents of the while & handle exiting the while afterwards
                                                                                        tagCount--;
                                                                                    }
                                                                                }
      
;
    
IfTail:     Block                                                               {
                                                                                    fprintf(yyout, "-IFTAIL STATEMENT-\n"); //Grammar output
                                                                                    $$ = $1; //Propagate tree
                                                                                }
            | Block ELSE    {
                                fprintf(irOut,"\tj ENDIF%d\nELSE%d: \n", tagCount, tagCount);
                            } 
                            
                            Block                                               {
                                                                                    fprintf(yyout, "-ELSE STATEMENT-\n"); //Grammar output
                                                                                    $$ = newNode("If tail", $1, $4); //Node management
                                                                                }
;

Expr:   Primary                                                                 { 
                                                                                    // Most of the time this rule is a terminal, refers to the Primary rule
                                                                                    fprintf(yyout,"---PRIMARY | (%d)---\n",lineCount);
                                                                                    $$ = $1;
                                                                                }
        | Expr LOGICAL Expr                                                     {   
                                                                                    // The rule for logical expressions used in boolean checks (||,==,&&) 
                                                                                    fprintf(yyout, "-LOGICAL EXPRESSION OP (%s)-\n", $2);
                                                                                    $$ = newNode($2, $1, $3); //AST node management

                                                                                    printf("----- RELATIONAL ---- (%s, %s)\n",$1->nodeType, $3->nodeType);

                                                                                    char * ty1;
                                                                                    char * ty2;
                                                                                    char * reg1;
                                                                                    char * reg2;
                                                                                    bool pass = false;

                                                                                    if(strcmp($1->type, "") != 0 && strcmp($3->type, "") != 0) {

                                                                                        printf("- 1 - (%s,%s)\n", $1->type, $3->type);

                                                                                        reg1 = $1->data->tempRegister;
                                                                                        reg2 = $3->data->tempRegister;

                                                                                        if(strcmp($1->type, $3->type) == 0)  {
                                                                                            strcpy(ty1, $1->type);
                                                                                            pass = true;
                                                                                        }

                                                                                    // Left expr has a node type
                                                                                    } else if (strcmp($1->type, "") != 0) {

                                                                                        printf("- 2 -\n");
                                                                                        ty1 = getTypeOfUnknown($3, stack);
                                                                                        reg2 = getReg($3->nodeType, stack);

                                                                                        reg1 = $1->data->tempRegister;

                                                                                        if(strcmp(ty1, $1->type) == 0) pass = true;
                                                                                    
                                                                                    // Right expr has a node type
                                                                                    }else if (strcmp($3->type, "") != 0) {

                                                                                        printf("- 3 -\n");
                                                                                        ty1 = getTypeOfUnknown($1, stack);
                                                                                        reg1 = getReg($1->nodeType, stack);

                                                                                        reg2 = $3->data->tempRegister;
                                                                                        
                                                                                        if(strcmp(ty1, $3->type) == 0) pass = true;

                                                                                    // Both exprs do not have a node type
                                                                                    } else {

                                                                                        ty1 = getTypeOfUnknown($1, stack);
                                                                                        ty2 = getTypeOfUnknown($3, stack);
                                                                                        
                                                                                        reg1 = getReg($1->nodeType, stack);
                                                                                        reg2 = getReg($3->nodeType, stack);

                                                                                        if(strcmp(ty1, ty2) == 0) pass = true;
                                                                                    }   

                                                                                    // if stamtments that checks the operands of the operator are of type int or float
                                                                                    if(strcmp(ty1, "int") != 0 && strcmp(ty1, "float") != 0) {
                                                                                        printf("##### SEMANTIC ERROR: Operators only use floats or ints! %s in %s", $1->nodeType, peek(stack));
                                                                                    }

                                                                                    if(strcmp(ty2, "int") != 0 && strcmp(ty2, "float") != 0) {
                                                                                        printf("##### SEMANTIC ERROR: Operators only use floats or ints! %s in %s", $3->nodeType, peek(stack));
                                                                                    }

                                                                                    if (!pass)                    
                                                                                    {
                                                                                        printf("##### SEMANTIC ERROR: Type check failed! (%s, %s) in %s\n", $1->nodeType, $3->nodeType, peek(stack));
                                                                                    } else {
                                                                                        strcpy($$->type, "bool");
                                                                                        // fprintf(irOut,"\t%s, %s, %s\n", $2, $1->nodeType, $3->nodeType);

                                                                                        if(checkSingleInt(reg1)) {
                                                                                            printf("1 is a number\n");
                                                                                            checkSign($2,reg2,reg1,peek(stack),tagCount,irOut);
                                                                                        } else if(checkSingleInt(reg2)) {
                                                                                            printf("2 is a number\n");
                                                                                            checkSign($2,reg1,reg2,peek(stack),tagCount,irOut);
                                                                                        } else {
                                                                                            printf("Both are regs! %s , %s\n", reg1, reg2);
                                                                                            checkSign($2,reg1,reg2,peek(stack),tagCount,irOut);
                                                                                        }
                                                                                    }
                                                                                }
        | Expr RELATIONAL Expr                                                  {   
                                                                                    // This rule deals with the relational operators for comparing values.
                                                                                    // (>=, <=, >, <)
                                                                                    fprintf(yyout, "-REALATIONAL EXPRESSION OP (%s)-\n", $2);
                                                                                    $$ = newNode($2, $1, $3);

                                                                                    printf("----- RELATIONAL ---- (%s, %s)\n",$1->nodeType, $3->nodeType);

                                                                                    char * ty1;
                                                                                    char * ty2;
                                                                                    char * reg1;
                                                                                    char * reg2;
                                                                                    bool pass = false;

                                                                                    if(strcmp($1->type, "") != 0 && strcmp($3->type, "") != 0) {

                                                                                        printf("- 1 - (%s,%s)\n", $1->type, $3->type);

                                                                                        reg1 = $1->data->tempRegister;
                                                                                        reg2 = $3->data->tempRegister;

                                                                                        if(strcmp($1->type, $3->type) == 0)  {
                                                                                            strcpy(ty1, $1->type);
                                                                                            pass = true;
                                                                                        }

                                                                                    // Left expr has a node type
                                                                                    } else if (strcmp($1->type, "") != 0) {

                                                                                        printf("- 2 -\n");
                                                                                        ty1 = getTypeOfUnknown($3, stack);
                                                                                        reg2 = getReg($3->nodeType, stack);

                                                                                        reg1 = $1->data->tempRegister;

                                                                                        if(strcmp(ty1, $1->type) == 0) pass = true;
                                                                                    
                                                                                    // Right expr has a node type
                                                                                    }else if (strcmp($3->type, "") != 0) {

                                                                                        printf("- 3 -\n");
                                                                                        ty1 = getTypeOfUnknown($1, stack);
                                                                                        reg1 = getReg($1->nodeType, stack);

                                                                                        reg2 = $3->data->tempRegister;
                                                                                        
                                                                                        if(strcmp(ty1, $3->type) == 0) pass = true;

                                                                                    // Both exprs do not have a node type
                                                                                    } else {

                                                                                        ty1 = getTypeOfUnknown($1, stack);
                                                                                        ty2 = getTypeOfUnknown($3, stack);
                                                                                        
                                                                                        reg1 = getReg($1->nodeType, stack);
                                                                                        reg2 = getReg($3->nodeType, stack);

                                                                                        if(strcmp(ty1, ty2) == 0) pass = true;
                                                                                    }   

                                                                                    // if stamtments that checks the operands of the operator are of type int or float
                                                                                    if(strcmp(ty1, "int") != 0 && strcmp(ty1, "float") != 0) {
                                                                                        printf("##### SEMANTIC ERROR: Operators only use floats or ints! %s in %s", $1->nodeType, peek(stack));
                                                                                    }

                                                                                    if(strcmp(ty2, "int") != 0 && strcmp(ty2, "float") != 0) {
                                                                                        printf("##### SEMANTIC ERROR: Operators only use floats or ints! %s in %s", $3->nodeType, peek(stack));
                                                                                    }

                                                                                    if (!pass)                    
                                                                                    {
                                                                                        printf("##### SEMANTIC ERROR: Type check failed! (%s, %s) in %s\n", $1->nodeType, $3->nodeType, peek(stack));
                                                                                    } else {
                                                                                        strcpy($$->type, "bool");

                                                                                        if(checkSingleInt(reg1)) {
                                                                                            printf("1 is a number\n");
                                                                                            checkSign($2,reg2,reg1,peek(stack),tagCount,irOut);
                                                                                        } else if(checkSingleInt(reg2)) {
                                                                                            printf("%s is a number\n", reg2);
                                                                                            checkSign($2,reg1,reg2,peek(stack),tagCount,irOut);
                                                                                        } else {
                                                                                            printf("Both are regs! %s , %s\n", reg1, reg2);
                                                                                            checkSign($2,reg1,reg2,peek(stack),tagCount,irOut);
                                                                                        }
                                                                                    }
                                                                                }
        | Expr '+' Expr                                                         {   
                                                                                    // This rule handles the addition of two expressions, can be recursive depending on what Expr returns
                                                                                    //Can be used for terminals as well
                                                                                    fprintf(yyout, "-ADD OP (%d)-\n", lineCount + 1);
                                                                                    $$ = newNode("+", $1, $3);

                                                                                    printf("----- + ---- (%s, %s)\n",$1->nodeType, $3->nodeType);

                                                                                    char * ty1;
                                                                                    char * ty2;
                                                                                    char * reg1;
                                                                                    char * reg2;
                                                                                    bool pass = false;

                                                                                    if(strcmp($1->type, "") != 0 && strcmp($3->type, "") != 0) {

                                                                                        printf("- 1 - (%s,%s)\n", $1->type, $3->type);

                                                                                        reg1 = $1->data->tempRegister;
                                                                                        reg2 = $3->data->tempRegister;

                                                                                        if(strcmp($1->type, $3->type) == 0)  {
                                                                                            strcpy(ty1, $1->type);
                                                                                            pass = true;
                                                                                        }

                                                                                    // Left expr has a node type
                                                                                    } else if (strcmp($1->type, "") != 0) {

                                                                                        printf("- 2 -\n");
                                                                                        ty1 = getTypeOfUnknown($3, stack);
                                                                                        reg2 = getReg($3->nodeType, stack);

                                                                                        reg1 = $1->data->tempRegister;

                                                                                        if(strcmp(ty1, $1->type) == 0) pass = true;
                                                                                    
                                                                                    // Right expr has a node type
                                                                                    }else if (strcmp($3->type, "") != 0) {

                                                                                        printf("- 3 -\n");
                                                                                        ty1 = getTypeOfUnknown($1, stack);
                                                                                        reg1 = getReg($1->nodeType, stack);

                                                                                        reg2 = $3->data->tempRegister;
                                                                                        
                                                                                        if(strcmp(ty1, $3->type) == 0) pass = true;

                                                                                    // Both exprs do not have a node type
                                                                                    } else {

                                                                                        ty1 = getTypeOfUnknown($1, stack);
                                                                                        ty2 = getTypeOfUnknown($3, stack);
                                                                                        
                                                                                        reg1 = getReg($1->nodeType, stack);
                                                                                        reg2 = getReg($3->nodeType, stack);

                                                                                        if(strcmp(ty1, ty2) == 0) pass = true;
                                                                                    }   


                                                                                    //Check flag for errors in type checking:
                                                                                    if (!pass) 
                                                                                    {
                                                                                        printf("##### SEMANTIC ERROR: Type check failed! (%s, %s) in %s\n", $1->nodeType, $3->nodeType, peek(stack));
                                                                                    } else {
                                                                                        strcpy($$->type, ty1);
                                                                                        char * regOut = returnTempVal();

                                                                                        if(checkSingleInt(reg1)) {
                                                                                            fprintf(irOut, "\taddi %s, %s, %s\n", regOut, reg2, reg1); 
                                                                                        } else if(checkSingleInt(reg2)) {
                                                                                            fprintf(irOut, "\taddi %s, %s, %s\n", regOut, reg1, reg2); 
                                                                                        } else {
                                                                                            fprintf(irOut, "\tadd %s, %s, %s\n", regOut, reg1, reg2); 
                                                                                        }

                                                                                        $$->data = setNodeData("", regOut);
                                                                                    }
                                                                                    
                                                                                }
        | Expr '-' Expr                                                         {
                                                                                    //This rule handles the subtraction of two expressions, can be recursive depending on what Expr returns
                                                                                    //Can be used for terminals as well
                                                                                    fprintf(yyout, "-SUB OP (%d)-\n", lineCount + 1);
                                                                                    $$ = newNode("-", $1, $3);

                                                                                    printf("----- - ---- (%s, %s)\n",$1->nodeType, $3->nodeType);

                                                                                    char * ty1;
                                                                                    char * ty2;
                                                                                    char * reg1;
                                                                                    char * reg2;
                                                                                    bool pass = false;

                                                                                    if(strcmp($1->type, "") != 0 && strcmp($3->type, "") != 0) {

                                                                                        printf("- 1 - (%s,%s)\n", $1->type, $3->type);

                                                                                        reg1 = $1->data->tempRegister;
                                                                                        reg2 = $3->data->tempRegister;

                                                                                        if(strcmp($1->type, $3->type) == 0)  {
                                                                                            strcpy(ty1, $1->type);
                                                                                            pass = true;
                                                                                        }

                                                                                    // Left expr has a node type
                                                                                    } else if (strcmp($1->type, "") != 0) {

                                                                                        printf("- 2 -\n");
                                                                                        ty1 = getTypeOfUnknown($3, stack);
                                                                                        reg2 = getReg($3->nodeType, stack);

                                                                                        reg1 = $1->data->tempRegister;

                                                                                        if(strcmp(ty1, $1->type) == 0) pass = true;
                                                                                    
                                                                                    // Right expr has a node type
                                                                                    }else if (strcmp($3->type, "") != 0) {

                                                                                        printf("- 3 -\n");
                                                                                        ty1 = getTypeOfUnknown($1, stack);
                                                                                        reg1 = getReg($1->nodeType, stack);

                                                                                        reg2 = $3->data->tempRegister;
                                                                                        
                                                                                        if(strcmp(ty1, $3->type) == 0) pass = true;

                                                                                    // Both exprs do not have a node type
                                                                                    } else {

                                                                                        ty1 = getTypeOfUnknown($1, stack);
                                                                                        ty2 = getTypeOfUnknown($3, stack);
                                                                                        
                                                                                        reg1 = getReg($1->nodeType, stack);
                                                                                        reg2 = getReg($3->nodeType, stack);

                                                                                        if(strcmp(ty1, ty2) == 0) pass = true;
                                                                                    }   

                                                                                    if (!pass) 
                                                                                    {
                                                                                        printf("##### SEMANTIC ERROR: Type check failed! (%s, %s) in %s\n", $1->nodeType, $3->nodeType, peek(stack));

                                                                                    } else {
                                                                                        strcpy($$->type, ty1);
                                                                                        char * regOut = returnTempVal();

                                                                                        if(checkSingleInt(reg1)) {
                                                                                            fprintf(irOut, "\tsubi %s, %s, %s\n", regOut, reg2, reg1); 
                                                                                        } else if(checkSingleInt(reg2)) {
                                                                                            fprintf(irOut, "\tsubi %s, %s, %s\n", regOut, reg1, reg2); 
                                                                                        } else {
                                                                                            fprintf(irOut, "\tsub %s, %s, %s\n", regOut, reg1, reg2); 
                                                                                        }

                                                                                        $$->data = setNodeData("", regOut);
                                                                                    }

                                                                                }
        | Expr '/' Expr                                                         {
                                                                                    //This rule handles the division of two expressions, can be recursive depending on what Expr returns
                                                                                    //Can be used for terminals as well

                                                                                    //Semantic checks to be added, check for 0 denominator. i.e. undefined 
                                                                                    fprintf(yyout, "-DIV OP (%d)-\n", lineCount + 1);
                                                                                    $$ = newNode("/", $1, $3);

                                                                                    printf("----- / ---- (%s, %s)\n",$1->nodeType, $3->nodeType);

                                                                                    char * ty1;
                                                                                    char * ty2;
                                                                                    bool pass = false;

                                                                                    if(strcmp($1->type, "") != 0 && strcmp($3->type, "") != 0) {

                                                                                        printf("- 1 - (%s,%s)\n", $1->type, $3->type);

                                                                                        if(strcmp($1->type, $3->type) == 0)  {
                                                                                            strcpy(ty1, $1->type);
                                                                                            pass = true;
                                                                                        }

                                                                                    // Left expr has a node type
                                                                                    } else if (strcmp($1->type, "") != 0) {

                                                                                        printf("- 2 -\n");
                                                                                        ty1 = getTypeOfUnknown($3, stack);

                                                                                        if(strcmp(ty1, $1->type) == 0) pass = true;
                                                                                    
                                                                                    // Right expr has a node type
                                                                                    }else if (strcmp($3->type, "") != 0) {

                                                                                        printf("- 3 -\n");
                                                                                        ty1 = getTypeOfUnknown($1, stack);
                                                                                        
                                                                                        if(strcmp(ty1, $3->type) == 0) pass = true;

                                                                                    // Both exprs do not have a node type
                                                                                    } else {

                                                                                        printf("- 4 -\n");
                                                                                        ty1 = getTypeOfUnknown($1, stack);
                                                                                        ty2 = getTypeOfUnknown($3, stack);
                                                                                    }

                                                                                    if (!pass) 
                                                                                    {
                                                                                        printf("##### SEMANTIC ERROR: Type check failed! (%s, %s) in %s\n", $1->nodeType, $3->nodeType, peek(stack));
                                                                                    } else {
                                                                                        strcpy($$->type, ty1);
                                                                                    }
                                                                                }
        | Expr '*' Expr                                                         {
                                                                                    //This rule handles the multiplication of two expressions, can be recursive depending on what Expr returns
                                                                                    //Can be used for terminals as well

                                                                                    //Semantic checks to be added
                                                                                    fprintf(yyout, "-MULT OP (%d)-\n", lineCount + 1);
                                                                                    $$ = newNode("*", $1, $3);

                                                                                    printf("----- * ---- (%s, %s)\n",$1->nodeType, $3->nodeType);

                                                                                    char * ty1;
                                                                                    char * ty2;
                                                                                    bool pass = false;

                                                                                    if(strcmp($1->type, "") != 0 && strcmp($3->type, "") != 0) {

                                                                                        printf("- 1 - (%s,%s)\n", $1->type, $3->type);

                                                                                        if(strcmp($1->type, $3->type) == 0)  {
                                                                                            strcpy(ty1, $1->type);
                                                                                            pass = true;
                                                                                        }

                                                                                    // Left expr has a node type
                                                                                    } else if (strcmp($1->type, "") != 0) {

                                                                                        printf("- 2 -\n");
                                                                                        ty1 = getTypeOfUnknown($3, stack);

                                                                                        if(strcmp(ty1, $1->type) == 0) pass = true;
                                                                                    
                                                                                    // Right expr has a node type
                                                                                    }else if (strcmp($3->type, "") != 0) {

                                                                                        printf("- 3 -\n");
                                                                                        ty1 = getTypeOfUnknown($1, stack);
                                                                                        
                                                                                        if(strcmp(ty1, $3->type) == 0) pass = true;

                                                                                    // Both exprs do not have a node type
                                                                                    } else {

                                                                                        printf("- 4 -\n");
                                                                                        ty1 = getTypeOfUnknown($1, stack);
                                                                                        ty2 = getTypeOfUnknown($3, stack);

                                                                                        if(strcmp(ty1, ty2) == 0) pass = true;
                                                                                    }

                                                                                    if (!pass) 
                                                                                    {
                                                                                        printf("##### SEMANTIC ERROR: Type check failed! (%s, %s) in %s\n", $1->nodeType, $3->nodeType, peek(stack));
                                                                                    } else {
                                                                                        strcpy($$->type, ty1);
                                                                                    }
                                                                                }
        | ID EQ Expr                                                            {
                                                                                    //This rule handles setting ID's equal to expressions, Expr being the only nonterminal in this rule
                                                                                    //Can be used for terminals as well
                                                                                    fprintf(yyout, "-ASSIGNMENT EQ (%s)-\n", $2);
                                                                                    $$ = newNode("=", terminalNode($1), $3);
                                                                            
                                                                                    // Semantic and type checks
                                                                                    char * nodeStr = NULL;
                                                                                    char * remainder = strstr(ops, $3->nodeType);
                                                                                    bool succeeded = false;

                                                                                    if(checkKind($1, stack) != 2) {
                                                                                        printf("##### SEMANTIC ERROR: ID in assignment statment is not a variable! (%s) in %s\n", $1, peek(stack));
                                                                                        errorCounter++;
                                                                                    }

                                                                                    
                                                                                    printf("Check '=': (%s, %s, %s)----------\n", $1, $3->nodeType, peek(stack));

                                                                                    if(strcmp($3->type, "") != 0) {
                                                                                        printf("- 1 -\n");
                                                                                        char * ty = getTypeInRecentScope($1, stack);
                                                                                        nodeStr = $3->nodeType;
                                                                                        if(strcmp(ty, $3->type) == 0) succeeded = true;

                                                                                    }
                                                                                    else if(checkForTerminal($3) != 1) {
                                                                                        printf("- 2 -\n");
                                                                                        nodeStr = checkExperNodeType($3);
                                                                                        succeeded = typeCheck($1, nodeStr, stack);
                                                                                    } else {
                                                                                        printf("- 3 -\n");
                                                                                        nodeStr = $3->nodeType;
                                                                                        succeeded = typeCheck($1, nodeStr, stack);
                                                                                    } 

                                                                                    if(!succeeded) {
                                                                                        printf("##### SEMANTIC ERROR: Type check failed! (%s, %s) in %s\n", $1, nodeStr, peek(stack));
                                                                                        errorCounter++;
                                                                                    } else {
                                                                                        // After the type check succeeds, the IR code is generated for setting a variable.
                                                                                        // fprintf(irOut, "%s: .word %s\n\t.text\n\tlw $t0, %s\n", $1, nodeStr, $1); // FIXME

                                                                                        if($3->data != NULL) {
                                                                                            fprintf(irOut,"\tmove %s, %s\n", getReg($1, stack), $3->data->tempRegister);
                                                                                            // Free in temp array
                                                                                            int tempNumber = $3->data->tempRegister[2] - '0';
                                                                                            cleanTemp(tempNumber);
                                                                                            // Free register in node data
                                                                                            strcpy($3->data->tempRegister,"");

                                                                                        } else if(nodeStr != NULL) {
                                                                                            // Needs to be expaneded to fit other situations 
                                                                                            // Only works for setting 
                                                                                            fprintf(irOut,"\tlw %s, %s\n", getReg($1, stack), $1);
                                                                                        }
                                                                                        
                                                                                    }
                                                                                    
                                                                                    //SYMBOL TABLE management: Store the actual value of the variable in the symbol table:
                                                                                    sym = findSymInRecentScope($1, stack);
                                                                                    installContents(sym, $3->nodeType, 0);
                                                                                    
                                                                                    // Move to Decl, and save a string with the .space variable to create an empty variable
                                                                                    // Turn to its own function
                                                                                    if(strcmp(peek(stack), "global") == 0 ){

                                                                                        bool isInData = false;
                                                                                        for(int i = 0; i <= globalDataIndex; i++) {
                                                                                            if(globalDataOut->dataStrings[i] == NULL) continue;
                                                                                            if(strcmp(globalDataOut->dataStrings[i], $1) == 0) isInData = true;
                                                                                        }
                                                                                        if(!isInData) {
                                                                                            globalDataOut->dataStrings[globalDataIndex] = $1;
                                                                                            globalDataOut->vals[globalDataIndex] = $3->nodeType;
                                                                                            globalDataIndex++;
                                                                                            printf("Added global variable!\n");
                                                                                        }
                                                                                    }
                                                                                }
        | ID OPEN_BRACKET Expr CLOSED_BRACKET EQ Expr                           {
                                                                                    //This rule handles the assignment of arrays, as long as the Expr is all int's, this rule is valid
                                                                                    // Can be used for terminals, any arithmetic calculation for an Expr will end with an int for the index.
                                                                                    fprintf(yyout, "-ARRAY ASSIGNMENT EQ (%d)-\n", lineCount);
                                                                                    $$ = newLeftNode($1, newNode("=", $3, $6));
                                                                                    
                                                                                    //Semantic and type checks:
                                                                                    char * nodeStr;

                                                                                    char * remainder1 = strstr(ops, $3->nodeType);
                                                                                    char * remainder2 = strstr(ops, $6->nodeType);   
                                                                                    if (remainder1 == NULL && remainder2 == NULL){
                                                                                        printf("Check Array '=': (%s, %s, %s, %s)----------\n", $1, $3->nodeType, $6->nodeType,peek(stack));

                                                                                        if(checkKind($1, stack) != 1) {
                                                                                            printf("##### SEMANTIC ERROR: %s is not an array! (%s)\n", $1, peek(stack));
                                                                                            errorCounter++;
                                                                                        }

                                                                                        if(checkForTerminal($6) != 1) {
                                                                                            nodeStr = checkExperNodeType($6);
                                                                                        } else {
                                                                                            nodeStr = $6->nodeType;
                                                                                        } 
                                                                                            
                                                                                        if(!typeCheck($1, nodeStr, stack)){
                                                                                            printf("##### SEMANTIC ERROR: Type check failed! (%s, %s) in %s\n", $1, nodeStr, peek(stack));
                                                                                            errorCounter++;
                                                                                        }

                                                                                        // Gets type of the array index and returns an error if its not int
                                                                                        char * eType = getTypeOfUnknown($3, stack);
                                                                                        if(strcmp(eType, "int") != 0) {
                                                                                            printf("##### SEMANTIC ERROR: Array index for %s is not an int! in %s\n", $1, peek(stack));
                                                                                            errorCounter++;
                                                                                        }

                                                                                        if(checkKind($1, stack) != 1) {
                                                                                            printf("##### SEMANTIC ERROR: %s is not an array! %s\n", $1, peek(stack));
                                                                                            errorCounter++; 
                                                                                        } else {
                                                                                            // Prints the three address code for an array assignment:
                                                                                            fprintf(irOut,"\tlw %s, ArraySizeLabelName\n la %s, %s", returnTempVal(),returnTempVal(),$1);
                                                                                        }
                                                                                    }
                                                                                    
                                                                                    //Symbol Table management: locate the symbol and add the correct contents to the correct index:
                                                                                    symbol * currentSym = findSymInRecentScope($1, stack);
                                                                                    int theIndex = atoi($3->nodeType);
                                                                                    installContents(currentSym, $6->nodeType, theIndex);

                                                                                    arrayDataOut->dataStrings[arrayDataIndex] = $1;
                                                                                    arrayDataOut->vals[arrayDataIndex] = $3->nodeType;
                                                                                    arrayDataIndex++;
                                                                                }
;

Primary:    ID                                                                  {
                                                                                    fprintf(yyout, "-ID REFERENCE (%s)-\n", $1); //Parsing
                                                                                    $$ = terminalNode($1); //AST node management
                                                                                }
            | NUMBER                                                            {
                                                                                    fprintf(yyout, "-NUMBER (%d)-\n", $1); //parsing
                                                                                    sprintf(inttoStr, "%d", $1); //Type conversion
                                                                                    $$ = terminalNode(inttoStr); //Node management
                                                                                }
            | FLOAT                                                             {
                                                                                    fprintf(yyout, "-FLOAT (%s)-\n", $1);
                                                                                    $$ = terminalNode($1); 
                                                                                    printf("%s\n", $1);
                                                                                }
            | STRING                                                            {   
                                                                                    fprintf(yyout, "-STRING (%s)-\n", $1); //Parsing
                                                                                    
                                                                                    char stringName[] = "str";
                                                                                    char stringIndex[3];

                                                                                    sprintf(stringIndex, "%d", dataIndex);
                                                                                    strcat(stringName, stringIndex);

                                                                                    $$ = terminalNode(stringName); //AST node management
                                                                                    strcpy($$->type, "string");

                                                                                    dataOut->dataStrings[dataIndex] = $1;
                                                                                    dataIndex++;
                                                                                }
            | OPEN_PARENTHESIS Expr CLOSED_PARENTHESIS                          { 
                                                                                    fprintf(yyout, "-( EXPRESSION ) | (%d)-\n", lineCount + 1); //Parsing output
                                                                                    $$ = newLeftNode("()", $2); //AST node management
                                                                                }
            | ID OPEN_PARENTHESIS   { 
                                        parameterCount = 0; //Before parameters are counted reset the parameter count to 0
                                    } 

                                    ExprList CLOSED_PARENTHESIS                 {
                                                                                    fprintf(yyout, "-FUNCTION CALL (%s)-\n", $1);
                                                                                    $$ = newNode("Call", terminalNode($1), $4);

                                                                                    //Semantic Check: The number of parameters used in a function call is the same as the number of parameters when it was declared:
                                                                                    sym = findSymInRecentScope($1, stack); //First, retrieve the function's symbol
                                                                                    int numParams = retrieveLength(sym); //Then get the function's parameter count
                                                                                    //Test parameter count of call against declaration:
                                                                                    if (parameterCount != numParams)
                                                                                    {
                                                                                        printf("##### SEMANTIC ERROR: Number of parameters in function call does not match declaration for function: %s\n", $1);
                                                                                        errorCounter++; 
                                                                                    }
                                                                                    else { //Print count checking of parameters, should be the same:
                                                                                        printf("Parameters in Declaration: %d\n", numParams);
                                                                                        printf("Parameters in Function Call: %d\n", parameterCount);
                                                                                    }
                                                                                }
            | ID OPEN_PARENTHESIS   { 
                                        parameterCount = 0; 
                                    } 
                                    
                                    CLOSED_PARENTHESIS                          {
                                                                                    fprintf(yyout, "-FUNCTION CALL (%s)-\n", $1); //Parsing output
                                                                                    $$ = newLeftNode("Call", terminalNode($1)); //AST node management

                                                                                    //SEMANTIC CHECK: Functions of a certain number of parameters cannot be called without those parameters
                                                                                    sym = findSymInRecentScope($1, stack);
                                                                                    int numParams = retrieveLength(sym);
                                                                                    if (parameterCount != numParams)
                                                                                    {
                                                                                        printf("##### SEMANTIC ERROR: Function with Parameters must be called with those parameters.\n");
                                                                                        errorCounter++;
                                                                                    }
                                                                                    else { //Check should return the same value when correct
                                                                                        printf("Parameters in Declaration: %d\n", numParams);
                                                                                        printf("Parameters in Function Call: %d\n", parameterCount);
                                                                                    }
                                                                                    

                                                                                }
            | ID OPEN_BRACKET Expr CLOSED_BRACKET                               {
                                                                                    fprintf(yyout, "-ARRAY REFERENCE (%s)-\n", $1); //Parser output
                                                                                    $$ = newNode("Array", terminalNode($1), $3); //AST node management

                                                                                    //Type/kind checking:
                                                                                    char * remainder = strstr(ops, $3->nodeType); 
                                                                                    bool succeeded = false;

                                                                                    if (remainder == NULL){

                                                                                        if(checkKind($1, stack) != 1) {
                                                                                            printf("##### SEMANTIC ERROR: %s is not an array! in %s\n", $1, peek(stack));
                                                                                            errorCounter++; 
                                                                                        }

                                                                                        // Gets type of the array index and returns an error if its not int
                                                                                        char * eType = getTypeOfUnknown($3, stack);
                                                                                        if(strcmp(eType, "int") != 0) {
                                                                                            printf("##### SEMANTIC ERROR: Array index for %s is not an int! in %s\n", $1, peek(stack));
                                                                                            errorCounter++;
                                                                                        }
                                                                                    }
                                                                                }
;

ExprList:                                                                       {   
                                                                                    fprintf(yyout, "---EPSILON (EXPRLIST) | (%d)---\n",lineCount); //Parsing output
                                                                                    $$ = NULL; //ASt management
                                                                                }
            | ExprListTail                                                      {
                                                                                    fprintf(yyout, "---EXPRESSION LIST TAIL | (%d)---\n",lineCount); //Parsing output
                                                                                    $$ = $1; //AST management
                                                                                }
;

ExprListTail:   Expr { parameterCount++; }                                      {
                                                                                    fprintf(yyout, "---EXPRESSION (ELT) | (%d)---\n",lineCount); //Parsing output
                                                                                    $$ = $1; //AST management
                                                                                    printf("Func call\n");

                                                                                    sym = findSymInRecentScope($1->nodeType, stack);
                                                                                    if(sym->contents[0] == NULL) {
                                                                                        printf("##### SEMANTIC ERROR: ID (%s) not defined in (%s)\n", $1->nodeType, peek(stack));
                                                                                        errorCounter++; //increment
                                                                                    }
                                                                                }                                                              
                | Expr { parameterCount++; } COMMA ExprListTail                 { 
                                                                                    
                                                                                    fprintf(yyout, "---EXPRESSION W LIST TAIL | (%d)---\n",lineCount); //PArsing output
                                                                                    $$ = newNode(",", $1, $4); //AST management

                                                                                    sym = findSymInRecentScope($1->nodeType, stack);
                                                                                    if(sym->contents[0] == NULL) {
                                                                                        printf("##### SEMANTIC ERROR: ID (%s) not defined in (%s)\n", $1->nodeType, peek(stack));
                                                                                        errorCounter++; //increment
                                                                                    }
                                                                                }
;

%%

int main(int argc, char**argv)
{
    /*
	    #ifdef YYDEBUG
		    yydebug = 1;
	    #endif
    */

	if(argc < 2) {
        printf("Execute with input file path");
        return(0);
    }
    
    yyin = fopen(argv[1], "r");
    yyout = fopen("Out.txt", "w");
    irOut = fopen("irOut.txt", "w");

    //First, initialize the symbol table with some null placeholders
    init_symbol_table();
    initMips();

    //Initialize stack for controlling the scope:
    stack = createStack(100);
    push(stack, "global");

    // Initialize and print temp and func array
    setTempArr();
    setFuncArr();

    dataOut = newDataSection(50);
    globalDataOut = newDataSection(50);
    arrayDataOut = newDataSection(50);

    //Then, throughout the parser, the symbol table will be manipulated
    //Additionally, throughout the parser, the scope stack will be manipulated
    fprintf(irOut,".text \n");
    fprintf(irOut,".globl main \n");

    yyparse();

    // Add symbols - needs to be added throughout bison portion above
    
    symbol_table_dump();
    // printStack(stack);

    printf("TOTAL ERRORS IN CODE ---------------------> %d\n", errorCounter);
    fprintf(irOut,"\n\n.data \n");
    for(int i = 0; i < dataIndex; i++) {
        fprintf(irOut,"\tstr%d: .asciiz\t%s\n", i, dataOut->dataStrings[i]);
    }

    free(dataOut);

    for(int i = 0; i < globalDataIndex; i++) {
        if(globalDataOut->vals[i] != NULL) {
            fprintf(irOut,"\t%s:\t .word\t %s\n", globalDataOut->dataStrings[i], globalDataOut->vals[i]);
        }
    }

    free(globalDataOut);

    printf("%d\n", arrayDataIndex);
    for(int i = 0; i < arrayDataIndex; i++) {
        if(arrayDataOut->vals[i] != NULL) {
            fprintf(irOut,"\t%s:\t .space\t %s\n", arrayDataOut->dataStrings[i], arrayDataOut->vals[i]);
        }
    }

    free(arrayDataOut);

    // Initialize and print temp array
    // printOutTempArr();
    // printOutFuncArr();
    
    fclose(yyin);
    fclose(yyout);
}


void yyerror(const char* s) {
	fprintf(stderr, "Parse error: %s\n", s);
	exit(1);
}



