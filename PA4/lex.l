%{
    #include "yacc.tab.h"
    #include <stdio.h>
    #include <string.h>
    void yyerror (const char *);
%}

Digit [0-9]
Id [0-9]+

%%
[\n]    { yylineno++; }
[#](.|[\t]|[ ])*[\n]  { yylineno++;}
[I][N][P][U][T] {  return INPUT; }
[O][U][T][P][U][T]  {return OUTPUT;}
[B][U][F][F] { return BUF; }
[N][O][T]   { return NOT; }
[A][N][D]  { return AND; }
[N][A][N][D] { return NAND; }
[O][R]      { return OR; }
[N][O][R]   { return NOR; }
[X][O][R]   { return XOR; }
[N][X][O][R] { return NXOR; }
{Id}        {
                yylval.name = strdup(yytext);
                return ID;
            }
[ ]         { ;}
.           { return yytext[0]; }
%%

int yywrap()
{
    return 1;
}

void yyerror(const char *msg)
{
    if(msg[0] == 's')
        printf("Line %d: %s with token '%s'\n", yylineno, msg, yytext);
    else
        printf("Line %d: %s\n", yylineno, msg);
}




