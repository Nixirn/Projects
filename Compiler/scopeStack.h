/* 
    Name: Erick Lagunas, Alita Rodriguez, Gaj Carson 
    Class: CST-405
    Date: 10 / 31 / 21
    Prof: Isac Artzi
    Description: This program is a Lexical Analyzer for the C--/gcupl language
*/


//Header file for management of scope stack
// C program for array implementation of stack
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>

// A structure to represent a stack
struct Stack {
	int top;
	unsigned capacity; //How big the stack is
	char ** array; //Array is the contents. For our purposes, we wish to store the current scope
};

// function to create a stack of given capacity. It initializes size of
// stack as 0
struct Stack* createStack(unsigned capacity)
{
	struct Stack* stack = (struct Stack*)malloc(sizeof(struct Stack)); //Allocate ye stack
	stack->capacity = capacity;
	stack->top = -1;
	stack->array = (char**)malloc(stack->capacity * sizeof(char*));
	return stack;
}

// Stack is full when top is equal to the last index
int isFull(struct Stack* stack)
{
	return stack->top == stack->capacity - 1;
}

// Stack is empty when top is equal to -1
int isEmpty(struct Stack* stack)
{
	return stack->top == -1;
}

// Function to add an item to stack. It increases top by 1
void push(struct Stack* stack, char* item)
{
	if (isFull(stack))
		return;
	stack->array[++stack->top] = item;
	//printf("%s pushed to stack\n", item);
}

// Function to remove an item from stack. It decreases top by 1
char * pop(struct Stack* stack)
{
	if (isEmpty(stack))
		return NULL;
	return stack->array[stack->top--];
}

// Function to return the top from stack without removing it
char * peek(struct Stack* stack)
{
	if (isEmpty(stack))
		return NULL; //If the stack is empty it will try to access the -1 index, which is not possible
	return stack->array[stack->top];
}

char * peekUnder(struct Stack* stack)
{
	//Note that this particular function will need some error handling because the top of the stack needs to be at least equal to 1, meaning there are two things on the stack
	if( stack->top >= 1)
	{
		printf("Checking under top of stack. . . ");
		printf("%s\n", stack->array[(stack->top - 1)]);
		return stack->array[(stack->top - 1)];
	}
	else
	{
		printf("Not enough items on the stack to access under the top.");
		return NULL;
	}

}

//We should have another utility function for debugging that will return the contents of the stack in their entirety
void printStack(struct Stack* stack)
{
    printf("--------- SCOPE STACK --------\n");
    for (int i = stack->top; i >= 0; i--)
    {
        printf("%s\n", stack->array[i]);
    }
    printf("-------- END SCOPE STACK -------\n");   
}

// Driver program to test above functions
// int main()
// {
// 	struct Stack* stack = createStack(100);

// 	push(stack, 10);
// 	push(stack, 20);
// 	push(stack, 30);

// 	printf("%d popped from stack\n", pop(stack));

// 	return 0;
// }
