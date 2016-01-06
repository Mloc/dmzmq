#ifndef POLLING_H
#define POLLING_H

#include "base.h"

#include <zmq.h>
#include <stdlib.h>

typedef struct
{
    zmq_pollitem_t *items;
    int *socket_ids;
    size_t size;
} dmzmq_pollset;

void dmzmq_free_pollset(void *data);
dmzmq_pollset *dmzmq_parse_pollset(const char *poll_str);

void dmzmq_polling_setup();
void dmzmq_polling_shutdown();

DLL_EXPORT char *dmzmq_pollread(int n, char **v);
DLL_EXPORT char *dmzmq_pollnext(int n, char **v);

#endif//POLLING_H
