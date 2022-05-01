#include <stdio.h>
#include <math.h>
#include <string.h>
#include <stdint.h>
#include <stdbool.h>
#include <stdlib.h>

/* 
    Name: Erick Lagunas, Alita Rodriguez, Gaj Carson 
    Class: CST-405
    Date: 10 / 31 / 21
    Prof: Isac Artzi
    Description: This program is a Lexical Analyzer for the C--/gcupl language
*/

typedef struct data
{
    char ** dataStrings;
    char ** vals;
} 
data;

typedef struct code
{
    char * function;
    char ** lines;
    int index;
} 
code;   

extern int errorCounter;
char ** tempArr;
char ** FuncArr;
char ** ReturnArr;

int codeIndex = 0;

code * mipsCode[25];

void initMips() {
    for(int i=0; i < 25; i++) {
        mipsCode[i] = NULL;
    }
}

code * createNewCode(char * name) {

    printf("%s <-------------- \n", name);

    code * newCode = (code*) malloc(sizeof(code)); 
    newCode->function = name;
    newCode->index = 0;
    newCode->lines = (char**)malloc(200 * sizeof(char*));

    printf("%s <-------------- \n", newCode->function);
    return newCode;
}

void addMipsSection(char * scope) {
    code * c = (code*) malloc(sizeof(code));
    c =  createNewCode(scope);
    printf("-------> at %d\n", codeIndex);
    mipsCode[codeIndex] = c;
    printf(" %s \n", mipsCode[codeIndex]->function);
    codeIndex++;

}

int addCode(char * funcName, char * line) {
    for(int i = 0; i < codeIndex; i++) {
        printf("ADDING -----\n");
        if(strcmp(mipsCode[i]->function, funcName) == 0) {
            printf("----- FOUND ----- %s\n", mipsCode[i]->function);
            int ind = mipsCode[i]->index;
            mipsCode[i]->lines[ind] = strdup(line);
            mipsCode[i]->index += 1;
            return 1;
        }
    }
    return 0;
}

void printMipsCode(FILE * out) {

    printf("\t ----- MIPS CODE ----- \n");
    for(int i = 0; i < codeIndex; i++) {
        printf("%d\n",mipsCode[i]->index);
        for (int j = 0; j < mipsCode[i]->index; j++)
        {
            printf("%s", mipsCode[i]->lines[j]);
        }
    }
}



data * newDataSection(int size) {
    data * newData = (data*) malloc(sizeof(data));
    newData->dataStrings = (char**)malloc(size * sizeof(char*));
    newData->vals = (char**)malloc(size * sizeof(char*));
    return newData;
}

char * getType(char * name, char * scope) {
    symbol * sym = symbol_table_findsym(name, scope);
    if(sym == NULL) return NULL;

    // D: printf("Name> %s Scope> %s\n", sym->name, sym->scope);
    return sym->type;
}

//Sometimes the scope will not be the same as what is on the stack so we need to search the stack:
symbol * findSymInRecentScope(char * name, struct Stack* stack)
{
    //To do this, we will first need to iterate through the stack:
    //NOTE that the correct scope will be the most recent scope that has a matching name
    //Start at the top of the stack and iterate until the bottom of the stack is reached:
    for (int i = stack->top; i >= 0; i--)
    {
        //Check whether find sym returns null or not for that stack:
        //First, if find sym does return a null value, the symbol of that name does not exist within that scope
        
        if (symbol_table_findsym(name, stack->array[i]) != NULL)
        {
            //A symbol was found with the desired name and scope, return that one
            printf("%s on the symbol table!\n", name);
            return symbol_table_findsym(name, stack->array[i]);
        }
        else //There does not exist a symbol of that name within this scope, check the next scope
        {
            // printf("Still Searching for name within recent scopes. . . ");
        }
    }

    return NULL;
}

char * getReg(char * name, struct Stack * stack) {
    char * reg = NULL;
    symbol * temp = findSymInRecentScope(name, stack);

    if (temp == NULL) {
        reg = name;
    } else {
        reg = temp->reg;
    }
    
    return reg;
}

char * getTypeInRecentScope(char * name, struct Stack* stack) {
    symbol * sym = findSymInRecentScope(name, stack);
    if(sym == NULL) return NULL;

    // D: printf("Name> %s Scope> %s\n", sym->name, sym->scope);
    return sym->type;
}


// Checks if a string is an int
bool checkSingleInt(char * str1) {
    // Gets length of the passed in string
    size_t len = strlen(str1);

    // Loops throught the string passed in and returns false if any character is not a diggit
    for(int i = 0; i < len; i++) {
        if(isdigit(str1[i]) == 0) {
            if(str1[i] != '0') {
                return false;
            }
        }
    }

    return true;
}

int searchConditionals(struct Stack* stack) {
    for(int i = stack->top; i >= 0; i--) {
        if(strcmp(stack->array[i], "IF") != 0 && strcmp(stack->array[i], "WHILE") != 0) {
            return i;
        }
    }

    return -1;
}

// Checks if two strings are ints
bool checkInt(char * str1, char * str2) {
    bool oneIsNumber = false;
    bool twoIsNumber = false;

    // Checks both strings individualy with a separate function
    oneIsNumber = checkSingleInt(str1);
    twoIsNumber = checkSingleInt(str2);

    // Returns true if both functions returned true
    if(!oneIsNumber || !twoIsNumber)
        return false;
    else 
        return true;

}

// Checks if both parameters are characters
bool checkChar(char * str1, char * str2) {

    // If statment that sees if the strings have only a single character
    if(sizeof(str1) == 1 && sizeof(str2) == 1) {

        // IF statment that checks if the single character is in the alphabet
        if(isalpha(str1[0]) != 0 && isalpha(str2[0]) != 0 )
            return true;

    // One or both parameters are not chars
    } else return false;
}

// Checks if both strings are boolean values
bool checkBool(char * str1, char * str2) {
    bool oneIsBool = false;
    bool twoIsBool = false;

    // Checks if str1 is the string true or false
    if(strcmp(str1, "true") == 0 || strcmp(str1, "false") == 0) {
        oneIsBool = true;
    }

    if(strcmp(str2, "true") == 0 || strcmp(str2, "false") == 0) {
        twoIsBool = true;
    }

    // Returns false if both or one parameter is not a boolean
    if(!oneIsBool || !twoIsBool)
        return false;
    else 
        return true;
}

// Checks if both parameters are float values
bool checkSinglefloat(char * str1) {
    bool hasDot = false;
    bool hasNonInt = false;
    size_t len = strlen(str1);

    printf("%s\n", str1);

    for(int i = 0; i < len; i++) {
        if(str1[i] == '.' && !hasDot) {
            hasDot = true;
        } else if (str1[i] == '.' && hasDot) {
            return false;
        } else if (isdigit(str1[i]) == 0) {
            if(str1[i] == '0') {
                continue;
            } else if(str1[i] == '\0') {
                continue;
            } else {
                return false;
            }
        }
    }
    
    if (hasDot) return true;
}

// Perameters are asssumed to be on the symbol table already
// Function that uses other functions to compair two strings multiple times for different types
bool typeCheckExprs(char * expr1, char * expr2) {
    if(checkInt(expr1, expr2)){
        return true;
    } else if (checkBool(expr1, expr2)) {
        return true;
    } else if (checkChar(expr1, expr2)){
        return true;
    } else return false;
}

// Perameters can be either symboles or other items not stored in the symbol tabel (numbers, floats, chars)
// Returns 1 if name1 is not on the table and 2 for name2 not being in the tabel. 3 if both are not in the table. 
// Checks if the strings passed in are in the symbol table
int typeCheckSymbols(char * name1, char * name2, struct Stack* stack){

    // Statmets that call a function that attemps to find the strings on the symbol table
    symbol * sym1 = findSymInRecentScope(name1, stack);
    symbol * sym2 = findSymInRecentScope(name2, stack);

    // If both parameters are not on the tabel return 3
    if(sym1 == NULL && sym2 == NULL){
        return 3;
    }

    // If one of the parameters is on the symbol table return either one or two
    if(sym1 == NULL) {
        return 1;
    } else if (sym2 == NULL) {
        return 2;
    }

    // If the types of the symbols found do not match return -1 else 0
    if(strcmp(sym1->type, sym2->type) != 0) {
        return -1;

    } else return 0;
}

// Returns the type of an unknown that is not on the symbol table 
char * checkUnknown(char * str){
    
    char * type;

    // If, else if statments that check if a string is a type recognised
    if (checkSingleInt(str)){ 
        
        type = "int";

    } else if(sizeof(str) == 1 && atoi(str) == 0 && strcmp(type, "") == 0) {

        type = "char";

    } else if(strcmp(str, "true") == 0 || strcmp(str, "false") == 0 ){

        type = "bool"; 

    } else if (checkSinglefloat(str)) {

        type = "float";

    } else {

        type = NULL;
    }

    return type;
}

// Expr can be a number or an id of a variable not on the symbole table
// Compares the types of a symbol and an unknown
bool typeCheckSymExpr(char * name, char * expr, struct Stack* stack){ 

    symbol * sym = findSymInRecentScope(name, stack);
    char * check = checkUnknown(expr);

    // This can be refacterd into its own function
    if(sym->type != NULL && check != NULL) { 

        if(strcmp(check, sym->type) != 0){

            return false;

        } else return true;
    }

    printf("(%s) could not be type checked!\n", expr);
    return false;
}

// Uses multiple functions to check two strings to see if they are of the same type
bool typeCheck(char * expr1, char * expr2, struct Stack* stack) {
    int checkTypeNumber = typeCheckSymbols(expr1, expr2, stack);
    bool returnBool = false;

    printf("In Type Check\n");

    // Switch that runs a check based on what typeCheckSymbols returns
    switch (checkTypeNumber)
    {
        case 0:
            printf("Type Check: 0\n");
            returnBool = true;
            break;
        case 1:
            printf("Type Check: 1\n");
            returnBool = typeCheckSymExpr(expr2, expr1, stack);
            break;
        case 2:
            printf("Type Check: 2\n");
            returnBool = typeCheckSymExpr(expr1, expr2, stack);
            break;
        case 3:
            printf("Type Check: 3\n");
            returnBool = typeCheckExprs(expr1, expr2);
            break;
        default:
            break;
    }

    return returnBool;
}

// Takes an ast node and returns the left node depending on its nodetype
char * checkExperNodeType(struct AST * exprTree) {
    if(strcmp(exprTree->nodeType, "Call") == 0 || strcmp(exprTree->nodeType, "Array") == 0){
        return getNodeType(exprTree->left);
    }

    return NULL;
}

// Checks the kind of a symbol passed in 
int checkKind(char * name, struct Stack* stack) {
    symbol * sym = findSymInRecentScope(name, stack);
    
    if(strcmp(sym->kind, "arrayDecl") == 0) {
        return 1;
    } else if(strcmp(sym->kind, "varDecl") == 0) {
        return 2;
    } else if(strcmp(sym->kind, "funcDecl") == 0) {
        return 3;
    } else {
        return 0;
    }
}

// Gets the type of an unknown that may or may not be on the symbole table
char * getTypeOfUnknown(struct AST * node, struct Stack* stack) {
    char * str;
    symbol * sym;

    // If statment triggered of the node passed in is not terminal
    if(checkForTerminal(node) != 1) {

        // Checks if the nonterminal is a function call or an array and returns the id located on the left node
        str = checkExperNodeType(node);

        // Looks for the symbol in its most recent scope and returns its type
        sym = findSymInRecentScope(str, stack);
        printf("%s\n", sym->type);
        return sym->type;
    } else {

        // Checks if the nodeType of the terminal node is a symbol and returns it
        sym = findSymInRecentScope(node->nodeType, stack);
        str = node->nodeType;

        // If a symbol was returned then returned type, else call checkUnknown to attempt to get a type
        if( sym != NULL) 
            return sym->type;
        else 
            return checkUnknown(str);
    }
}

// Set Array that initializes the array that will keep track of the temp registers
void  setTempArr() {

    tempArr = calloc(8,sizeof(char*));

    tempArr[0] = "$t0";
    tempArr[1] = "$t1";
    tempArr[2] = "$t2";
    tempArr[3] = "$t3";
    tempArr[4] = "$t4";
    tempArr[5] = "$t5";
    tempArr[6] = "$t6";
    tempArr[7] = "$t7";
}
// Set Array that initializes the array that will keep track of the function registers
void  setFuncArr() {

    FuncArr = calloc(4,sizeof(char*));
    
    FuncArr[0] = "$a0";
    FuncArr[1] = "$a1";
    FuncArr[2] = "$a2";
    FuncArr[3] = "$a3";

}
// Set Array that initializes the array that will keep track of the return registers
void  setReturnArr() {

    ReturnArr = calloc(2,sizeof(char*));
    
    ReturnArr[0] = "$v0";
    ReturnArr[1] = "$v1";
}
// Returns the string of the temporary register needed for MIPS
char * returnTempVal(){
    char * registerDec = NULL; 
    for(int i = 0; i < 8; i++)
    {
        if(strcmp(tempArr[i], "") != 0)
        {
            registerDec = strdup(tempArr[i]);
            tempArr[i] = strdup("");
            return registerDec;
        }
        
    }
}
// Returns the string of the return register needed for MIPS
char * returnRetVal(){
    char * registerDec = NULL; 
    for(int i = 0; i < 2; i++)
    {
        if(strcmp(ReturnArr[i], "") != 0)
        {
            registerDec = strdup(ReturnArr[i]);
            ReturnArr[i] = strdup("");
            return registerDec;
        }
        
    }
}

// Returns the string of the function register needed for MIPS

char * returnFuncVal(){
    char * registerDec = ""; 
    for(int i = 0; i < 4; i++)
    {
        if(strcmp(FuncArr[i], "") != 0)
        {
            registerDec = strdup(FuncArr[i]);
            FuncArr[i] = "";
            return registerDec;
        }
    }
}

// Gets the current string of the current index in the tempArray
char * getTemp(int index){
    return tempArr[index];
}

// Gets the current string of the current index in the FuncArray
char * getFunc(int index){
    return FuncArr[index];
}
// Gets the current string of the current index in the FuncArray
char * getRet(int index){
    return ReturnArr[index];
}


// Restore's the original temp register value in the array and clears past (no longer needed) data
void cleanTemp(int i){
     if (i == 0)
     {
        tempArr[0] = "$t0";
        return;
     }
     else if (i == 1)
     {
        tempArr[1] = "$t1";
        return;
     }
      else if (i == 2)
     {
        tempArr[2] = "$t2";
        return;
     }
      else if (i == 3)
     {
        tempArr[3] = "$t3";
        return;
     }
      else if (i == 4)
     {
        tempArr[4] = "$t4";
        return;
     }
      else if (i == 5)
     {
        tempArr[5] = "$t5";
        return;
     }
      else if (i == 6)
     {
        tempArr[6] = "$t6";
        return;
     }
     else if (i == 7)
     {
        tempArr[7] = "$t7";
        return;
     }
     else
     {
         printf("Invalid index, please pick a number from 1 to 7\n");
         return;
     }
}
// Restore's the original function register value in the array and clears past (no longer needed) data
void cleanFunc(int i){
     if (i == 0)
     {
        FuncArr[0] = "$a0";
        return;
     }
     else if (i == 1)
     {
        FuncArr[1] = "$a1";
        return;
     }
      else if (i == 2)
     {
        FuncArr[2] = "$a2";
        return;
     }
      else if (i == 3)
     {
        FuncArr[3] = "$a3";
        return;
     }
     else
     {
         printf("Invalid index, please pick a number from 0 to 3\n");
         return;
     }
     
    
}
// Restore's the original function register value in the array and clears past (no longer needed) data
void cleanRet(int i){
     if (i == 0)
     {
        ReturnArr[0] = "$v0";
        return;
     }
     else if (i == 1)
     {
        ReturnArr[1] = "$v1";
        return;
     }
      
     else
     {
         printf("Invalid index, please pick a number from 0 to 1\n");
         return;
     }
     
    
}
void printOutTempArr(){
  for(int i = 0; i < 8; i++)
  {
    printf("\n Temporary Array element is: %s \n", tempArr[i]);
  }
} 
void printOutFuncArr(){
  for(int i = 0; i <4; i++)
  {
    printf("\n Function Array element is: %s \n", FuncArr[i]);
  }
} 
void printOutRetArr(){
  for(int i = 0; i <2; i++)
  {
    printf("\n Return Array element is: %s \n", ReturnArr[i]);
  }
} 

/* MIPS Conditional Statement Key
    slt  $t1,$s1,$s0      # checks if $s0 > $s1
    bne  $t1,$zero,label1 # if $s0 >  $s1, goes to label1
    beq  $s1,$s2,label2   # if $s0 == $s2, goes to label2 
    # beq  $t1,$zero,label3 # if $s0 <  $s1, goes to label3
    b    label3            # only possibility left

    slt $at, $s1, $s0           # $s0 > $s1  as ($s1 < $s0) != 0
    bne $at, $zero, label1

    slt $t0, $s0, $s1           # $s0 >= $s1 as (s0<s1) == 0
    beq $t0, $zero, label2

    slt $t1, $s1, $s0           # $s0 <= $s1 the same but reversing the inputs
    beq $t1, $zero, label3

*/

void checkSign(char* sign, char* firstArg, char* secondArg, char* type, int tagNum, FILE * out)
{
    char * s = sign;
    char t[10];

    printf("\ntype of branch! %s\n", type);

    if(strcmp(type, "WHILE") == 0) {
        sprintf(t,"EXIT%d",tagNum);
        type = strdup(t);
    }

    if(strcmp(type, "IF") == 0)
    {
        if(strcmp(s, ">"))
            fprintf(out, "\tbgt %s, %s, ENDIF%d\n", firstArg, secondArg, tagNum);
        else if(strcmp(s, "<"))
            fprintf(out, "\tblt %s, %s, ENDIF%d\n", firstArg, secondArg, tagNum);   
        else if(strcmp(s, "<="))
            fprintf(out, "\tble %s, %s, ENDIF%d\n",firstArg, secondArg, tagNum);
        else if(strcmp(s, ">="))
            fprintf(out, "\tbge %s, %s, ENDIF%d\n", firstArg, secondArg, tagNum);
        else if(strcmp(s, "=="))
            fprintf(out, "\tbeq %s, %s, ENDIF%d \n", firstArg, secondArg, tagNum);
        else
        {
            printf("Error");
            return;
        }
    } else {
        if(strcmp(s, ">"))
            fprintf(out, "\tbgt %s, %s, %s\n", firstArg,secondArg,type);
        else if(strcmp(s, "<"))
            fprintf(out, "\tblt %s, %s, %s\n", firstArg, secondArg,type);   
        else if(strcmp(s, "<="))
            fprintf(out, "\tble %s, %s, %s\n", firstArg,secondArg, type);
        else if(strcmp(s, ">="))
            fprintf(out, "\tbge %s, %s, %s\n",firstArg, secondArg,type);
        else if(strcmp(s, "=="))
            fprintf(out, "\tbeq %s, %s, %s \n", firstArg, secondArg,type);
        else
        {
            printf("Error");
            return;
        }
    }
}