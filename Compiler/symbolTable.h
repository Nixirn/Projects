#include <stdio.h>
#include <math.h>
#include <string.h>
#include <stdint.h>
#include <stdbool.h>
#include <stdlib.h>
// Only add to the symbol table do not worry about the reference list rn

/* 
    Name: Erick Lagunas, Alita Rodriguez, Gaj Carson 
    Class: CST-405
    Date: 10 / 31 / 21
    Prof: Isac Artzi
    Description: This program is a Lexical Analyzer for the C--/gcupl language
*/

#define TABLE_SIZE 20
#define TYPE_SIZE 10
#define STRING_SIZE 50
#define CONTENT_CAPACITY 25

//Thought for optimization: Only allocate contents capacity of 25 if the symbol being created is of type Array
//Because otherwise the other symbol kinds are only ever going to use a single index for their contents

extern int errorCounter;

// Change to store ID, name, type, kind, array length (if array), (scope), etc
typedef struct symbol
{
    //Member declarations: these are the characteristics of each symbol
    char *name;  // stores the string but it cannot be modified, array strings can be!
    char *kind; //Stores varDecl, or funcDecl, or arrayDecl 
    char *type; //Int, char, bool, or void
    int length; //Specific to arrays when arrays declare a size, also specific to functions that declare a number of parameters
    char *scope; //either global or pertains to funcName();
    char ** contents; //Stores the actual value of something, for instance, x = 5, stores "5"
    char * reg;
} 
symbol;

symbol * symbol_table[TABLE_SIZE];

//When a symbol is made, the ID and scope need to be passed to this function before being hashed. 
int symbol_table_hash(char *name, char *scope) {

    int hash = 0;
    int nameLen = strlen(name);
    int scopeLen = strlen(scope);

    for(int i=0; i < nameLen; i++) {
        for (int j=0; j < scopeLen; j++)
        {
            hash += (name[i] ^ 3) /scope[j];
        }
    }
    
    hash = (hash * 47) % TABLE_SIZE;
    return hash;
}

void init_symbol_table() {
    for(int i=0; i < TABLE_SIZE; i++) {
        symbol_table[i] = NULL;
    }
}

//Prints the symbol table to the user:
void symbol_table_dump() {
    printf("-> START\n"); 

    for(int i=0; i < TABLE_SIZE; i++) {
        if(symbol_table[i] == NULL) {
            //A NULL entry should output: index#     ---    ---    ---    ---     ---     ---     ---
            printf("\t %d \t --- \t --- \t --- \t --- \t --- \n", i);
        } else {
            //A symbol table with entriesshould output: index[i]  name    kind    type    length  scope   contents
            printf("\t %d \t %s \t %s \t %s \t %d \t %s \t %s \t[", i, symbol_table[i]->name, symbol_table[i]->kind, symbol_table[i]->type, symbol_table[i]->length, symbol_table[i]->scope, symbol_table[i]->reg);
            //Now, at the end of the contents printed above, all of the indices of symboltable->contents[] have to be printed:
            for (int j=0; j < CONTENT_CAPACITY; j++) {
                if (symbol_table[i]->contents[j] == NULL) {
                    printf(" - ");
                }
                else {
                    printf(" %s ", symbol_table[i]->contents[j]);
                }
            }
            printf(" ] \n");
        }
    }

    printf("-> END\n");
}

symbol * create_symbol(char * name, char * kind, char * type, int length, char * scope) {
    symbol * newSym = (symbol*) malloc(sizeof(symbol));
    newSym->name = name;
    newSym->kind = kind;
    newSym->type = type;
    newSym->length = length;
    newSym->scope = scope;
    newSym->contents = (char**)malloc(CONTENT_CAPACITY * sizeof(char*)); //The array needs to have a size and is allocated to start out empty
    newSym->reg = NULL;
    return newSym;
}

void symbol_table_installsym(char * name, char * kind, char * type, int length, char * scope) {

    int index = symbol_table_hash(name, scope);
    symbol * sym = (symbol*) malloc(sizeof(symbol));
    sym = create_symbol(name, kind, type, length, scope);

    int count = 0;
    for(int i=0; i < TABLE_SIZE; i++) {
        count = (i + index) % TABLE_SIZE;

        // Checks of symbol is not null and also is equal to the symbol already on the table to return an error.
        if(symbol_table[count] != NULL) {
            if((strcmp(symbol_table[count]->name, sym->name) == 0) && (strcmp(symbol_table[count]->scope, sym->scope) == 0)) 
            {
                printf("##### SEMANTIC ERROR: '%s' already declared in %s!\n", sym->name, sym->scope); 
                errorCounter++;
                break;
            }
        }

        // if the location that the symbol is hashed to is empty, insert the symbol
        if(symbol_table[count] == NULL) {
            symbol_table[count] = sym;
            printf("symbolTable.h: %s in table!\n", name);
            break;
        }
    }
}

symbol * symbol_table_findsym(char * name, char * scope) {
    int index = symbol_table_hash(name, scope);
    int count = 0;

    for(int i=0; i < TABLE_SIZE; i++) {
        count = (i + index) % TABLE_SIZE;
        if(symbol_table[count] != NULL) {
            if((strcmp(symbol_table[count]->name, name) == 0) && (strcmp(symbol_table[count]->scope, scope) == 0)) 
            {
                return symbol_table[count]; 
            }
        }
    }
    return NULL;
}

//Now that we can successfully make the array that will hold the contents, we will need a separate function that will modify each index of the contents.
//To do so, how can we pass these contents into this function?
//First, in the parser.y file, the contents can be extracted as well as the desired index for assignment
//For instance: i[2] = 120 means that the index at 120 should be 

void installContents(symbol * currentSym, char * newContents, int index)
{
    //To install the contents, each of the indices from newContents must be copied to the indices in the contents of the current sym
    //In our test code, most of the assignments are of a single index: i[NUMBER] = content;
    currentSym->contents[index] = newContents;

}

void installReg(char * name, char * scope, char * reg) {
    symbol * temp = symbol_table_findsym(name, scope);  
    temp->reg = strdup(reg);
}

char * retrieveContents(symbol * currentSym, int index)
{
    //This function returns a single value at some index in the contents of a symbol
    return currentSym->contents[index];
}

int retrieveLength(symbol * currentSym)
{
    //Returns the value at a symbol's length (Note that length can contain the length of an array or the number of parameters of a function)
    return currentSym->length;
}

void installLength(symbol * currentSym, int newLength)
{
    currentSym->length = newLength;
}