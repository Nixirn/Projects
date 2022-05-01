//Abstract Syntax Tree Implementation
#include <string.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>

#define TABLE_SIZE 20
#define TYPE_SIZE 10
#define STRING_SIZE 50

//Declares the AST structs along with it's attributes 
struct AST{
	char nodeType[STRING_SIZE];
	char type[STRING_SIZE];
	
	struct AST * left;
	struct AST * right;
	struct nodeData * data;
};

struct nodeData{
	char value[STRING_SIZE];
	char tempRegister[8]; 
};

struct nodeData * setNodeData (char value[STRING_SIZE], char temp[8]) {
	struct nodeData * newData = (struct nodeData * ) malloc(sizeof(struct nodeData));
	strcpy(newData->tempRegister, temp);
	strcpy(newData->value, value);	
	return newData;
}	

// AST struct specifically for terminals, sets children for left and right to NULL
struct AST * terminalNode(char nodeType[STRING_SIZE]) {
	struct AST * termNode = (struct AST * ) malloc(sizeof(struct AST));
	strcpy(termNode->nodeType, nodeType);
	strcpy(termNode->type, "");
	termNode->data = NULL;
	termNode->left = NULL;
	termNode->right = NULL;

	return termNode;
}
//Creates a new left node where the right node -> null, in this tree, the left node cannot be null
struct AST * newLeftNode(char nodeType[STRING_SIZE], struct AST * left) {
	struct AST * leftNode = (struct AST * ) malloc(sizeof(struct AST));
	strcpy(leftNode->nodeType, nodeType);
	strcpy(leftNode->type, "");
	leftNode->data = NULL;
	leftNode->left = left;
	leftNode->right = NULL;

	return leftNode;
}
// Creates a new AST node taking in the left and right attributes
struct AST * newNode(char nodeType[STRING_SIZE], struct AST * left, struct AST * right) {
	struct AST * nonTermNode = (struct AST * ) malloc(sizeof(struct AST));
	strcpy(nonTermNode->nodeType, nodeType);
	strcpy(nonTermNode->type, "");
	nonTermNode->data = NULL;
	nonTermNode->left = left;
	nonTermNode->right = right;

	return nonTermNode;
}

// Returns node type of a node
char * getNodeType(struct AST * node) {
	if(node == NULL) return NULL;
	return node->nodeType;
}

// Checks if a node is terminal ( 1 = terminal, 0 = left, -1 = nonterminal)
int checkForTerminal (struct AST * node) {
	if(node->left == NULL && node->right == NULL) return 1;
	if(node->left != NULL && node->right == NULL) return 0;
	return -1;
}
// Helps to format the tree by printing the dots to show the trees levels
void printDots(int num)
{
	for (int i = 0; i < num; i++)
		printf("      ");
}

// Takes the string as an input, checks if it is a int string, returns the int
int stringToInt(char str[STRING_SIZE]) {
	
	if(isdigit(str[0])){
		return atoi(str);
	}
	else return -1;
}

void printSpaceToFile(int num, FILE * out) {
    for(int i = 0; i < num; i++) {
        fprintf(out,"      ");
    }
}

// Function for printing the AST tree, checks if the tree or any of its nodes are null, if they are return the root or just empty return.
void printAST(struct AST* tree, int level){

	if (tree == NULL) return;

	printDots(level);
	printf("%s \n", tree->nodeType);
	
    
	if(tree->left != NULL) {
		printAST(tree->left, level+1); 
	}else {
		return;
	}

	if(tree->right != NULL) {
		printAST(tree->right, level+1);
	} else {
		return;
	}
}
