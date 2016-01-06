#include "socket.h"

#include "base.h"
#include "config.h"
#include "dmzmq.h"

#include <stdlib.h>
#include <string.h>

int dmzmq_socktypes[] = {
    ZMQ_PAIR,
    ZMQ_PUB,
    ZMQ_SUB,
    ZMQ_REQ,
    ZMQ_REP,
    ZMQ_DEALER,
    ZMQ_ROUTER,
    ZMQ_PULL,
    ZMQ_PUSH,
    ZMQ_XPUB,
    ZMQ_XSUB,
    ZMQ_STREAM
};

void **dmzmq_socks;
int dmzmq_sock_l = 0; // lower bound for a blank spot in dmzmq_socks

void dmzmq_socket_setup()
{
    dmzmq_socks = calloc(DMZMQ_MAX_SOCKETS, sizeof(void*));
}

void dmzmq_socket_shutdown()
{
    int i;
    for(i = 0; i < DMZMQ_MAX_SOCKETS; i++)
    {
        if(dmzmq_socks[i] != NULL)
        {
            zmq_close(dmzmq_socks[i]);
        }
    }
    free(dmzmq_socks);
}

DLL_EXPORT char *dmzmq_socket(int n, char **v)
{
    DMZMQ_ASSERT(n == 1);
    DMZMQ_ASSERT(zmq_ctx != NULL);

    // find free slot in socks array
    int sock_n;
    for(sock_n = dmzmq_sock_l; sock_n < DMZMQ_MAX_SOCKETS; sock_n++)
    {
        if(dmzmq_socks[sock_n] == NULL)
        {
            break;
        }
    }
    if(sock_n == DMZMQ_MAX_SOCKETS) // couldn't find a free
    {
        return "ERR:OUTOFSOCKETS";
    }

    void *zmq_sock = zmq_socket(zmq_ctx, dmzmq_socktypes[(int)(v[0][0] - 'a')]);
    if(zmq_sock == NULL)
    {
        return dmzmq_strerrno();
    }

    dmzmq_socks[sock_n] = zmq_sock;
    dmzmq_sock_l = sock_n + 1;

    snprintf(return_buf, DMZMQ_RBUF_SIZE, "ZSD:%d", sock_n);
    return return_buf;
}

DLL_EXPORT char *dmzmq_close(int n, char **v)
{
    DMZMQ_ASSERT(n == 1);
    DMZMQ_ASSERT(zmq_ctx != NULL);

    int idx = atoi(v[0]);
    void *zmq_sock = dmzmq_socks[idx];
    DMZMQ_ASSERT(zmq_sock != NULL);

    zmq_close(zmq_sock);
    dmzmq_socks[idx] = NULL;
    if(idx < dmzmq_sock_l)
    {
        dmzmq_sock_l = idx;
    }

    return "";
}

DLL_EXPORT char *dmzmq_connect(int n, char **v)
{
    DMZMQ_ASSERT(n == 2);
    DMZMQ_ASSERT(zmq_ctx != NULL);

    void *zmq_sock = dmzmq_get_sock(atoi(v[0]));
    DMZMQ_ASSERT(zmq_sock != NULL);

    if(zmq_connect(zmq_sock, v[1]) == -1)
    {
        return dmzmq_strerrno();
    }
    return "";
}

DLL_EXPORT char *dmzmq_bind(int n, char **v)
{
    DMZMQ_ASSERT(n == 2);
    DMZMQ_ASSERT(zmq_ctx != NULL);

    void *zmq_sock = dmzmq_get_sock(atoi(v[0]));
    DMZMQ_ASSERT(zmq_sock != NULL);

    if(zmq_bind(zmq_sock, v[1]) == -1)
    {
        return dmzmq_strerrno();
    }
    return "";
}

DLL_EXPORT char *dmzmq_subscribe(int n, char **v)
{
    DMZMQ_ASSERT(n == 2);
    DMZMQ_ASSERT(zmq_ctx != NULL);

    void *zmq_sock = dmzmq_get_sock(atoi(v[0]));
    DMZMQ_ASSERT(zmq_sock != NULL);

    if(zmq_setsockopt(zmq_sock, ZMQ_SUBSCRIBE, v[1], strlen(v[1])) == -1)
    {
        return dmzmq_strerrno();
    }

    return "";
}

DLL_EXPORT char *dmzmq_send(int n, char **v)
{
    DMZMQ_ASSERT(n == 2);
    DMZMQ_ASSERT(zmq_ctx != NULL);

    void *zmq_sock = dmzmq_get_sock(atoi(v[0]));
    DMZMQ_ASSERT(zmq_sock != NULL);

    if(zmq_send(zmq_sock, v[1], strlen(v[1]), 0) == -1)
    {
        return dmzmq_strerrno();
    }
    else
    {
        return "";
    }
}

DLL_EXPORT char *dmzmq_recv(int n, char **v)
{
    DMZMQ_ASSERT(n == 1);
    DMZMQ_ASSERT(zmq_ctx != NULL);

    void *zmq_sock = dmzmq_get_sock(atoi(v[0]));
    DMZMQ_ASSERT(zmq_sock != NULL);

    sprintf(return_buf, "MSG:");

    int ret = zmq_recv(zmq_sock, return_buf + 4, DMZMQ_RBUF_SIZE - 5, 0);

    if(ret == -1)
    {
        return dmzmq_strerrno();
    }

    return_buf[4 + MIN(ret, DMZMQ_RBUF_SIZE - 5)] = '\0';

    return return_buf;
}

void *dmzmq_get_sock(int sock_id)
{
    return dmzmq_socks[sock_id];
}
