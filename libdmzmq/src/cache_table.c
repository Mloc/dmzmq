#include "cache_table.h"

#include <string.h>
#include <stdlib.h>
#include <stdint.h>
#include "murmurhash.h"

void *ct_init(size_t table_size, void (*cleanup_func)(void *))
{
    ct_table *table = malloc(sizeof(ct_table));

    table->size = table_size;
    table->entries = calloc(table_size, sizeof(ct_entry));
    table->cleanup_func = cleanup_func;

    return table;
}

void ct_free(ct_table *table)
{
    int i;
    for(i = 0; i < table->size; i++)
    {
        free(table->entries[i].key);
        void *val = table->entries[i].value;
        if(val != NULL)
        {
            table->cleanup_func(val);
        }
    }

    free(table->entries);
    free(table);
}

uint32_t ct_hash(const void *key, size_t key_len)
{
    uint32_t hash;
    MurmurHash3_x86_32(key, key_len, 0xf18ee3fa, &hash);
    return hash;
}

void ct_put(ct_table *table, const void *key, size_t key_len, void *val)
{
    uint32_t index = ct_hash(key, key_len) % table->size;
    ct_entry *entry = table->entries + index;
    
    entry->key = realloc(entry->key, key_len);
    entry->key_len = key_len;
    memcpy(entry->key, key, key_len);

    if(entry->value != NULL)
    {
        table->cleanup_func(entry->value);
    }
    entry->value = val;
}

void *ct_get(ct_table *table, const void *key, const size_t key_len)
{
    uint32_t index = ct_hash(key, key_len) % table->size;
    ct_entry *entry = table->entries + index;

    // early out
    if(entry->value == NULL)
    {
        return NULL;
    }
    else if(memcmp(entry->key, key, key_len) == 0)
    {
        return entry->value;
    }
    return NULL;
}
