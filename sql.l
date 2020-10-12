%{
#include <stdio.h>
#include "y.tab.h"

void yyerror(char *s);

%}

%%
CREATE {return CREATE;}
TABLE {return TABLE;}
INT {{yylval.s=strdup(yytext); return INT;}
VARCHAR {{yylval.s=strdup(yytext); return VARCHAR;}
"PRIMARY KEY" {return PRIMARY;}

SELECT {return SELECT;}
"*" {return ALL;}
FROM {return FROM;}
WHERE {return WHERE;}

"INSERT INTO" {return INSERT;}
VALUES {return VALUES;}

DELETE {return DELETE;}

[a-zA-Z0-9_]+ {yylval.s=strdup(yytext); return VAR;}

[;,()=] {return *yytext;}
[\n] |
[\r] {return NEW_LINE;}

[ \t]+  {}      
.	{printf("EROARE DE SINTAXA %s\n", yytext);}
%%

int yywrap(void)
{
    return 1;
}

 
