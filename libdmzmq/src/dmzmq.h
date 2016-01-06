#ifndef DMZMQ_H
#define DMZMQ_H

#include <zmq.h>
#include "base.h"

void *zmq_ctx;

char *return_buf;

char *dmzmq_strerrno();

DLL_EXPORT char *dmzmq_setup(int n, char **v);
DLL_EXPORT char *dmzmq_shutdown(int n, char **v);

#endif//DMZMQ_H
