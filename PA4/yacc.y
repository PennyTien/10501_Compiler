%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <math.h>
    #include <stdbool.h>
    #define YYERROR_VERBOSE 1
    enum{
        GATE_INPUT, GATE_OUTPUT, GATE_BUFFER, GATE_NOT, GATE_AND, GATE_NAND, GATE_OR, GATE_NOR, GATE_XOR, GATE_NXOR
    };
    
    struct wire{
        int gate_type;
        char *name;
        bool val;
        struct wire *inputA;
        struct wire *inputB;
    };
    
    struct node{
        struct wire line;
        struct node *next;
    }data, *nodePtr;
    
    struct list
    {
        char *output;
        struct list *next;
    }outputList, *listPtr;
    
    void wiring(int i, char *in1, char* out, char *in2);
    struct wire *getWire(char *, int );
    void addWire(struct node *index, char *target, int type);
    void printtheWire();
    void implement(struct wire *output, int value);
    void saveOutput(char *);
    void clearInput();
    void printResult();
    
%}

%union{
    char *name;
    int in, out, buf, not, and, nand, or, nor, xor, nxor;
}

%token <name>ID
%token <in>INPUT
%token <our>OUTPUT
%token <buf>BUF
%token <not>NOT
%token <and>AND
%token <nand>NAND
%token <or>OR
%token <nor>NOR
%token <xor>XOR
%token <nxor>NXOR

%%

file
:   line file
|   term
|
;
line
:   INPUT '(' ID ')'                        {wiring(GATE_INPUT, $3, $3, $3); printtheWire();}
|   OUTPUT '(' ID ')'                       {wiring(GATE_OUTPUT, $3, $3, $3); printtheWire();}
|   ID '=' BUF '(' ID ')'                   {wiring(GATE_BUFFER, $5, $5, $1); printtheWire();}
|   ID '=' NOT '(' ID ')'                   {wiring(GATE_NOT, $5, $5, $1); printtheWire();}
|   ID '=' AND '(' ID ',' ID ')'            {wiring(GATE_AND, $5, $7, $1); printtheWire();}
|   ID '=' NAND '(' ID ',' ID ')'            {wiring(GATE_NAND, $5, $7, $1); printtheWire();}
|   ID '=' OR '(' ID ',' ID ')'            {wiring(GATE_OR, $5, $7, $1); printtheWire();}
|   ID '=' NOR '(' ID ',' ID ')'            {wiring(GATE_NOR, $5, $7, $1); printtheWire();}
|   ID '=' XOR '(' ID ',' ID ')'            {wiring(GATE_XOR, $5, $7, $1); printtheWire();}
|   ID '=' NXOR '(' ID ',' ID ')'            {wiring(GATE_NXOR, $5, $7, $1); printtheWire();}
;
term
:   '\n'
;


%%

int main()
{
    yyparse();

    listPtr = &outputList;
    printf("\n");
    while(listPtr->next!=NULL)
    {
        listPtr = listPtr->next;
        struct wire *outputWire = getWire(listPtr->output, -2);
        implement(outputWire, 0);
    }
    printResult();
    clearInput();
    printf("\n-----------------------------------------------\n\n");
    listPtr = &outputList;
    while(listPtr->next!=NULL)
    {
        listPtr = listPtr->next;
        struct wire *outputWire = getWire(listPtr->output, -2);
        implement(outputWire, 1);
    }
    printResult();
    return 0;
}

void wiring(int type, char *in1, char* in2, char *out)
{
    struct wire *input1 = getWire(in1, -1);//int findGare, is cna't find the ID, create one
    struct wire *input2 = getWire(in2, -1);//remeber in findGate function if in2 is NULL then return directly
    struct wire *output = getWire(out, type);

    switch(type)
    {
        case GATE_INPUT:
            input1->gate_type = type;
            break;
        case GATE_OUTPUT:
            saveOutput(in1);
            return;
        case GATE_BUFFER:
            output->inputA = input1;
            break;
        case GATE_NOT:
            output->inputA = input1;
            break;
        case GATE_AND:
            output->inputA = input1;
            output->inputB = input2;
            break;
        case GATE_NAND:
            output->inputA = input1;
            output->inputB = input2;
            break;
        case GATE_OR:
            output->inputA = input1;
            output->inputB = input2;
            break;
        case GATE_NOR:
            output->inputA = input1;
            output->inputB = input2;
            break;
        case GATE_XOR:
            output->inputA = input1;
            output->inputB = input2;
            break;
        case GATE_NXOR:
            output->inputA = input1;
            output->inputB = input2;
            break;
    }
    
    if(output->gate_type == -1)
        output->gate_type = type;
}

struct wire *getWire(char *target, int type)
{
    //printf("at getWire! \n");
    nodePtr = &data;
    while(nodePtr->next != NULL)
    {
        nodePtr = nodePtr->next;
        if(strlen(target) == strlen(nodePtr->line.name))
        {
            for(size_t i=0; i<strlen(target); i++)
            {
                if(target[i]!=nodePtr->line.name[i])
                    break;
                else if(target[i] == nodePtr->line.name[i] && i==strlen(target)-1)
                    return &nodePtr->line;
            }
        }
    }
    if(type == -2)
    {
        printf("Error!!!!");
        exit(1);
    }
    addWire(nodePtr, target, type);
    nodePtr = nodePtr->next;
    return &nodePtr->line;
}

void addWire(struct node *index, char *target, int type)
{
    //printf("at addwire! %s \n", target);
    struct node *thenew;
    thenew = (struct node*) malloc (sizeof(struct node));
    
    thenew->line.name = strdup(target);
    thenew->line.gate_type = type;
    
    index->next = thenew;
}

void printtheWire()
{  // printf("\n");
    nodePtr = &data;
    while(nodePtr->next != NULL)
    {
        nodePtr = nodePtr->next;
       // printf("%s, type: %d \n", nodePtr->line.name, nodePtr->line.gate_type);
    }
}

void saveOutput(char *target)
{
    listPtr = &outputList;
    while(listPtr->next != NULL)
        listPtr=listPtr->next;
        
    struct list *temp;
    temp = (struct list*) malloc (sizeof(struct list));
    
    temp->output = strdup(target);
    listPtr->next = temp;
    listPtr = listPtr->next;
}

void implement(struct wire *currentW, int value)
{
    int bottom = currentW->gate_type;
    if(currentW->val == NULL)
    {
        if(bottom == 0)
        {
            currentW->val = value;
        }
        else if(bottom == 2 || bottom == 3)
        {
            implement(currentW->inputA, value);
        }
        else if(bottom > 3 )
        {
            implement(currentW->inputA, value);
            implement(currentW->inputB, value);
        }
    }
    
    switch(bottom)
    {
        case GATE_BUFFER:
            //printf("BUFFER:  OUTPUT:%s inputA is %s ", currentW->name, currentW->inputA->name);
            currentW->val = currentW->inputA->val;
            //printf(" ---- %d\n", currentW->val);
            break;
        case GATE_NOT:
           // printf("NOT:     OUTPUT:%s inputA is %s ",  currentW->name, currentW->inputA->name);
            currentW->val = !currentW->inputA->val;
            //printf(" ---- %d\n", currentW->val);
            break;
        case GATE_AND:
            //printf("AND      OUTPUT %s inputA is %s, inputB %s ", currentW->name, currentW->inputA->name, currentW->inputB->name);
            currentW->val = currentW->inputA->val & currentW->inputB->val;
            //printf(" ---- %d\n", currentW->val);
            break;
        case GATE_NAND:
  //          printf("NAND     OUTPUT %s inputA is %s, inputB %s " ,currentW->name, currentW->inputA->name, currentW->inputB->name);
            currentW->val = !(currentW->inputA->val & currentW->inputB->val);
    //        printf(" ---- %d\n", currentW->val);
            break;
        case GATE_OR:
      //      printf("OR       OUTPUT %s inputA is %s, inputB %s " ,currentW->name, currentW->inputA->name, currentW->inputB->name);
            if(currentW->inputA->val == false && currentW->inputB->val == false)
                currentW->val = false;
            else
                currentW->val = true;
        //    printf(" ---- %d\n", currentW->val);
            break;
        case GATE_NOR:
         //   printf("NOR      OUTPUT %s inputA is %s, inputB %s " ,currentW->name, currentW->inputA->name, currentW->inputB->name);
            if(currentW->inputA->val == false && currentW->inputB->val == false)
                currentW->val = true;
            else
                currentW->val = false;
           // printf(" ---- %d\n", currentW->val);
            break;
        case GATE_XOR:
           // printf("XOR      OUTPUT %s inputA is %s, inputB %s ", currentW->name, currentW->inputA->name, currentW->inputB->name);
            currentW->val = ((currentW->inputA->val & (!currentW->inputB->val)) | ((!currentW->inputA->val) & currentW->inputB->val));
            //printf(" ---- %d\n", currentW->val);
            break;
        case GATE_NXOR:
          //  printf("NXOR     OUTPUT %s inputA is %s-%d, inputB %s-%d ", currentW->name, currentW->inputA->name, currentW->inputA->val, currentW->inputB->name, currentW->inputB->val);
            currentW->val = !((currentW->inputA->val & (!currentW->inputB->val)) | ((!currentW->inputA->val) & currentW->inputB->val));
          //  printf(" ---- %d\n", currentW->val);
            break;
        default:
            break;
    }
   // printf("!Current %s type:%d val: %d\n", currentW->name, currentW->gate_type, currentW->val);



}



void clearInput()
{
    nodePtr = &data;
    while(nodePtr->next!=NULL)
    {
        nodePtr = nodePtr -> next;
        nodePtr->line.val = NULL;
    }
}

void printResult()
{
    listPtr = &outputList;
    
    while(listPtr->next!=NULL)
    {
        listPtr = listPtr -> next;
        
        char *target = listPtr->output;
        nodePtr = &data;
        while(nodePtr->next!=NULL)
        {
            nodePtr = nodePtr->next;
            if(strlen(target) == strlen(nodePtr->line.name))
            {
                for(size_t i=0; i<strlen(target); i++)
                {
                    if(target[i]!=nodePtr->line.name[i])
                        break;
                    else if(target[i] == nodePtr->line.name[i] && i==strlen(target)-1)
                        printf("%d",nodePtr->line.val);
                }
            }
        }
    }
}

























