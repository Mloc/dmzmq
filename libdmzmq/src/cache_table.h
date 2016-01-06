#ifndef CACHE_TABLE_H
#define CACHE_TABLE_H

#include <stdlib.h>

typedef struct
{
    void *key;
    size_t key_len;

    void *value;
} ct_entry;

typedef struct
{
    size_t size;
    void (*cleanup_func)(void *);

    ct_entry *entries;
} ct_table;

void *ct_init(size_t table_size, void (*cleanup_func)(void *));
void ct_free(ct_table *table);

void ct_put(ct_table *table, const void *key, size_t key_len, void *val);
void *ct_get(ct_table *table, const void *key, size_t key_len);

#endif//CACHE_TABLE_H
