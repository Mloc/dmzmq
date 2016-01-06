#include "dmzmq.h"

#include <zmq.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "base.h"
#include "config.h"

// for setup calls
#include "socket.h"
#include "polling.h"

char *dmzmq_strerrno()
{
    switch(errno)
    {
    case EFAULT:
        return "ERR:EFAULT";
    case EINTR:
        return "ERR:EINTR";
    case EINVAL:
        return "ERR:EINVAL";
    case EMFILE:
        return "ERR:EMFILE";
    case ETERM:
        return "ERR:ETERM";
    case EPROTONOSUPPORT:
        return "ERR:EPROTONOSUPPORT";
    case ENOCOMPATPROTO:
        return "ERR:ENOCOMPATPROTO";
    case ENOTSOCK:
        return "ERR:ENOTSOCK";
    case EMTHREAD:
        return "ERR:EMTHREAD";
    case EAGAIN:
        return "ERR:EAGAIN";
    case ENOTSUP:
        return "ERR:ENOTSUP";
    case EFSM:
        return "ERR:EFSM";
    case EHOSTUNREACH:
        return "ERR:EHOSTUNREACH";
    case EADDRINUSE:
        return "ERR:EADDRINUSE";
    case EADDRNOTAVAIL:
        return "ERR:EADDRNOTAVAIL";
    case ENODEV:
        return "ERR:ENODEV";
    default:
        return "ERR:_UNKNOWN_ERRNO";
    }
}

DLL_EXPORT char *dmzmq_setup(int n, char **v)
{
    DMZMQ_ASSERT(n == 0);
    DMZMQ_ASSERT(zmq_ctx == NULL);

    zmq_ctx = zmq_ctx_new();
    if(zmq_ctx == NULL)
    {
        return dmzmq_strerrno();
    }

    int ret = zmq_ctx_set(zmq_ctx, ZMQ_MAX_SOCKETS, DMZMQ_MAX_SOCKETS);
    if(ret == -1)
    {
        return dmzmq_strerrno();
    }

    return_buf = malloc(sizeof(char) * DMZMQ_RBUF_SIZE);

    dmzmq_socket_setup();
    dmzmq_polling_setup();

    return "API:"DMZMQ_API_VERSION;
}

DLL_EXPORT char *dmzmq_shutdown(int n, char **v)
{
    DMZMQ_ASSERT(n == 0);
    DMZMQ_ASSERT(zmq_ctx != NULL);

    free(return_buf);

    dmzmq_socket_shutdown();
    dmzmq_polling_shutdown();

    if(zmq_term(zmq_ctx) == -1)
    {
        return dmzmq_strerrno();
    }
    zmq_ctx = NULL;
    return "";
}
