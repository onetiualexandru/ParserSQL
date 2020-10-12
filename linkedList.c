#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>

#include "linkedList.h"

void *chkMalloc(size_t sz)
{
    void *mem = malloc(sz);

    // Just fail immediately on error.

    if (mem == NULL)
    {
        printf("Out of memory! Exiting.\n");
        exit(1);
    }

    // Otherwise we know it worked.

    return mem;
}

void addRow(row_node **first_row, char *row_data)
{
    //insert first
    row_node *new = chkMalloc(sizeof(*new));
    new->row_name = chkMalloc(strlen(row_data) + 1);
    strcpy(new->row_name, row_data);

    new->row_next = *first_row;
    *first_row = new;
}

void printRow(row_node *first)
{
    int i = 0;
    row_node *new = first;
    while (new != NULL)
    {
        printf("Row[%d] = %s\n", i, new->row_name);
        i++;
        new = new->row_next;
    }
    //printf("0k=%d\n", ok);
}

void addColumns(columns_list **columns_first, char *column_name, char *data_type, bool primary_key, row_node *rows)
{
    columns_list *new = chkMalloc(sizeof(*new));
    new->columns_name = chkMalloc(strlen(column_name + 1));
    strcpy(new->columns_name, column_name);
    new->columns_data_type = chkMalloc(strlen(data_type + 1));
    strcpy(new->columns_data_type, data_type);
    new->primary_key = primary_key;
    new->row_data_next = rows;

    new->columns_next = *columns_first;
    *columns_first = new;
}

int setPrimaryKey(columns_list *columns_list_head, char *column_name)
{
    //printf("%s\n", column_name);
    columns_list *new = columns_list_head;
    while (new != NULL)
    {
        if (!(strcmp(new->columns_name, column_name)))
        {
            new->primary_key = true;
            //printf("----------------%s\n", new->columns_name);
            return 0;
        }
        new = new->columns_next;
    }
    return -1;
}

void printColumn(columns_list *first)
{
    int i = 0;
    columns_list *new = first;
    while (new != NULL)
    {
        printf("------>Column[Key = %d ][Name = %s] [Type] = %s\n", new->primary_key, new->columns_name, new->columns_data_type);
        i++;
        printRow(new->row_data_next);
        new = new->columns_next;
    }
}

void mapColumnListToList(columns_map **columns_map_first, columns_list *column, char *map_name)
{
    columns_map *new = chkMalloc(sizeof(*new));
    new->map_name = chkMalloc(strlen(map_name + 1));
    strcpy(new->map_name, map_name);
    new->next_column = column;

    new->columns_map_next = *columns_map_first;
    *columns_map_first = new;
}

void printColumnListToList(columns_map *first)
{
    columns_map *new = first;
    int i = 0;
    while (new != NULL)
    {
        printf("------------>Table = %s<------------\n", new->map_name);
        //printf("col[%s]\n", new->next_column->columns_name);
        printColumn(new->next_column);
        new = new->columns_map_next;
        i++;
    }
}

void addTable(table_node **table_first, char *table_name, columns_map *cols)
{
    table_node *new = chkMalloc(sizeof(*new));
    new->table_name = chkMalloc(strlen(table_name + 1));
    strcpy(new->table_name, table_name);
    new->columns_data_next = cols;

    new->table_next = *table_first;
    *table_first = new;
}

void printTabel(table_node *first)
{
    table_node *new = first;
    while (new != NULL)
    {
        printf("------------>Table = %s<------------\n", new->table_name);
        printColumnListToList(new->columns_data_next);
        new = new->table_next;
    }
}

void mapTableToDatabase(database **database_first, table_node *table)
{
    database *new = chkMalloc(sizeof(*new));
    new->table_data_next = table;

    new->db_next = *database_first;
    *database_first = new;
}

void printTablesFromDatabase(database *first)
{
    database *new = first;
    int i = 0;
    while (new != NULL)
    {
        //printf("columns[%d]= %s\n", i, new->next_column->columns_name);
        printTabel(new->table_data_next);
        new = new->db_next;
        i++;
    }
}

table_node *searchTabelByName(database *db_head, char *table_name)
{
    //printf("%s\n", table_name);
    database *new = db_head;
    while (new != NULL)
    {
        if (!(strcmp(new->table_data_next->table_name, table_name)))
        {
            //printf("----------------%s\n", new->table_data_next->table_name);
            return new->table_data_next;
        }
        new = new->db_next;
    }
    return NULL;
}

columns_map *searchTableMap(table_node *table, char *map_name)
{
    table_node *new = table;
    while (new != NULL)
    {
        if (!(strcmp(new->columns_data_next->map_name, map_name)))
        {
            //printf("map_name=%s\n", new->columns_data_next->map_name);
            return new->columns_data_next;
        }

        new = new->table_next;
    }
    return NULL;
}

columns_list *searchColumnByNamme(columns_map *col_map, char *col_name)
{
    //printf("++++++++colname=%s\n", col_name);

    int i = 0;
    columns_map *new = col_map;
    columns_list *head = col_map->next_column;
    while (head != NULL)
    {
        //printf("COLL_name=%s\n", new->next_column->columns_name);
        if (!(strcmp(head->columns_name, col_name)))
        {
            //printf(">>>>>>>>>>>>>>>col_name=%s\n", head->columns_name);
            return head;
        }
        head = head->columns_next;
    }
    return NULL;
}

int checkRow(row_node *row, char *row_name)
{

    row_node *new = row;
    while (new != NULL)
    {
        if (!(strcmp(new->row_name, row_name)))
            return 1;
        new = new->row_next;
    }
    return -1;
}

int deleteRow(row_node **row, char *row_name)
{

    row_node *new = *row, *prev;
    if (new != NULL && !(strcmp(new->row_name, row_name)))
    {
        *row = new->row_next;
        free(new);
        return 1;
    }
    while (new != NULL && strcmp(new->row_name, row_name))
    {
        prev = new;
        new = new->row_next;
    }
    prev->row_next = new->row_next;
    free(row);
    if (new == NULL)
        return -1;
    else
        return 1;
}

void printOneColumn(columns_list *first)
{
    int i = 0;
    columns_list *new = first;

    printf("------>Column[Key = %d ][Name = %s] [Type] = %s\n", new->primary_key, new->columns_name, new->columns_data_type);
    i++;
    printRow(new->row_data_next);
}

void setRow(columns_list *column, row_node *row)
{
    column->row_data_next = row;
}

void insertRowAtEnd(row_node **row_head, char *row_data)
{
    row_node *current = *row_head;
    row_node *new = NULL;
    new = chkMalloc(sizeof(*new));
    new->row_name = chkMalloc(strlen(row_data) + 1);
    strcpy(new->row_name, row_data);
    new->row_next = NULL;
    if (current == NULL)
    {
        *row_head = new;
    }
    else
    {
        while (current->row_next != NULL)
        {
            current = current->row_next;
        }
        current->row_next = new;
    }
}
