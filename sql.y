%{
void yyerror (char *s);
#include <stdio.h>   
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

#include "linkedList.h"
extern int yylex();


columns_list *col_list = NULL;
columns_map *col_map = NULL;
table_node *table = NULL;
table_node *table_aux = NULL;
database *db = NULL;
char *col_name_cond, *col_data_cond;
int select_cond = 0;

char col_mem[4096], row_mem[4096];


void columnsCreate(char *col_name, char *col_type){

       addColumns(&col_list,col_name, col_type, false, NULL);
      
       
}

void setKey(char *col_name){

        if(setPrimaryKey(col_list, col_name)){
                printf("ERROR, column not found!\n");
                exit(1);
        }
}

void tableCreate(char *table_name){

        mapColumnListToList(&col_map, col_list, table_name);
        addTable(&table, table_name, col_map);
        mapTableToDatabase(&db,table);
        //printTablesFromDatabase(db);
        col_list = NULL;
        col_map = NULL;
        table = NULL;

}

void selectTable(char *table_name){
        table_aux = searchTabelByName(db,table_name);
        if(table_aux == NULL){
                printf("ERROR, Table does not exist!\n");
                exit(0);
        }
        columns_map *aux = searchTableMap(table_aux,table_name);
        if(aux == NULL){
                printf("ERROR, Cannot Retrieve Table!\n");
                exit(0);
        }

        if(select_cond == 1){
                
                printColumnListToList(aux);
        }
        else if(select_cond==2){

                columns_list *aux_col=searchColumnByNamme(aux,col_name_cond);
                if(aux_col == NULL){
                        printf("ERROR, Column doesn't exist!\n");
                        exit(0);
                }
                if(checkRow(aux_col->row_data_next,col_data_cond)==1)
                printOneColumn(aux_col);
                else
                {
                        printf("ERROR, Row dosn't exist!\n");
                }
        }
        else if(select_cond==3){
                 columns_list *aux_col=searchColumnByNamme(aux,col_name_cond);
                if(aux_col == NULL){
                        printf("ERROR, Column doesn't exist!\n");
                        exit(0);
                }
                if(deleteRow(&aux_col->row_data_next,col_data_cond)==1)
                printf("SUCCES\n");
                else
                {
                        printf("ERROR, Row dosn't exist!\n");
                }
        }
        else{
                printf("ERROR, Select Oparation Failed!\n");
                exit(0);
        }
}

row_node *row = NULL;

void insertTable(char *table_name){


        table_aux = searchTabelByName(db,table_name);
        if(table_aux == NULL){
                printf("ERROR, Table does not exist!\n");
                exit(0);
        }
        columns_map *aux = searchTableMap(table_aux,table_name);
        if(aux == NULL){
                printf("ERROR, Cannot Retrieve Table!\n");
                exit(0);
        }

       
       int col_len = strlen(col_mem);
       int row_len = strlen(row_mem);
       int count = 0;
       char col_name[256];
       char row_name[256];

       for (int i=0; i < col_len; i++)
                if(col_mem[i]==',')
                        count++;
        //printf("count=%d\n",count);

        int i=0, j=0;
        while(count!=0)
        {       
                int c=0, l=0;

                //extract column
                while(col_mem[i] != ',')
                {
                        col_name[c] = col_mem[i];
                        c++;
                        i++;
                }
                i++;
                c=0;
                //printf("col=%s\n",col_name);

                //extract row
                while(row_mem[j] != ',')
                {
                        row_name[l] = row_mem[j];
                        l++;
                        j++;
                }
                j++;
                l=0;
                //printf("row=%s\n",row_name);


                columns_list *aux_col=searchColumnByNamme(aux,col_name);
                //printf("%s\n",aux_col->columns_name);

                //setez pointer coloana la o lista de randuri
                //addRow(&row,row_mem);
                
               

                //insertRowAtEnd(&aux_col->row_data_next,row_mem);

                addRow(&aux_col->row_data_next,row_name);

                //insertRowAtEnd(&aux_col->row_data_next,row_mem);

                //setRow(aux_col,aux);
                //aux_col->row_data_next=NULL;*/

                //row = NULL;

                count--;
        }

}

%}

%union{
    char* s; 
}

%token VAR NEW_LINE CREATE TABLE INT VARCHAR PRIMARY SELECT ALL FROM WHERE INSERT VALUES DELETE
%type <s> VAR tip INT VARCHAR columns_to_insert instruction_INSERT row_data


%%

program : program expression NEW_LINE
        |
        ;

expression : instruction_CREATE 
           | instruction_SELECT
           | instruction_INSERT
           | instruction_DELETE
	   ;



instruction_CREATE : CREATE TABLE VAR '(' columns primary_key ')' ';'  {tableCreate($3);}
        ;

columns : VAR tip {columnsCreate($1,$2);}
        | VAR tip ',' columns {columnsCreate($1,$2);}
        |
        ;

tip     : VARCHAR 
        | INT 
        ;

primary_key : PRIMARY '(' VAR ')' {setKey($3);}
            |
            ;


instruction_SELECT : SELECT select_option FROM VAR select_condition ';' {selectTable($4);}
                   ;

select_option : ALL {select_cond = 1;}

select_condition : WHERE VAR '=' VAR {col_name_cond=$2;col_data_cond=$4; select_cond = 2;}
                 |
                 ;


instruction_INSERT : INSERT VAR '(' columns_to_insert ')' VALUES '(' row_data ')' ';' {insertTable($2);}
                   ;

columns_to_insert : 
          VAR {strcat(col_mem,$1);strcat(col_mem,",");}
        | columns_to_insert  ',' VAR {strcat(col_mem,$3);strcat(col_mem,",");}
        ;
row_data : VAR {strcat(row_mem,$1);strcat(row_mem,",");}
        | row_data ',' VAR  {strcat(row_mem,$3);strcat(row_mem,",");}
        ;


instruction_DELETE : DELETE FROM VAR WHERE VAR '=' VAR ';'{col_name_cond=$5;col_data_cond=$7; select_cond = 3; selectTable($3);}
                   ;

%%


int main (void) {

	return yyparse ( );
}

void yyerror (char *s) {fprintf (stderr, "%s\n", s);} 