#include "socket.h"

#include "base.h"
#include "config.h"
#include "dmzmq.h"

#include <stdlib.h>
#include <string.h>
#include <inttypes.h>

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

    void *zmq_sock = zmq_socket(zmq_ctx, atoi(v[0]));
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

DLL_EXPORT char *dmzmq_send(int n, char **v)
{
    DMZMQ_ASSERT(n == 3);
    DMZMQ_ASSERT(zmq_ctx != NULL);

    void *zmq_sock = dmzmq_get_sock(atoi(v[0]));
    DMZMQ_ASSERT(zmq_sock != NULL);

    if(zmq_send(zmq_sock, v[1], strlen(v[1]), atoi(v[2])) == -1)
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
    DMZMQ_ASSERT(n == 2);
    DMZMQ_ASSERT(zmq_ctx != NULL);

    void *zmq_sock = dmzmq_get_sock(atoi(v[0]));
    DMZMQ_ASSERT(zmq_sock != NULL);

    sprintf(return_buf, "MSG:");

    int flags = atoi(v[1]);
    int ret = zmq_recv(zmq_sock, return_buf + 4, DMZMQ_RBUF_SIZE - 5, flags);

    if(ret == -1)
    {
        return dmzmq_strerrno();
    }

    return_buf[4 + MIN(ret, DMZMQ_RBUF_SIZE - 5)] = '\0';

    return return_buf;
}


int int64_sockopts[] = DMZMQ_INT64_SOCKOPTS;
int int_sockopts[] = DMZMQ_INT_SOCKOPTS;
int str_sockopts[] = DMZMQ_STR_SOCKOPTS;

DLL_EXPORT char *dmzmq_setsockopt(int n, char **v)
{
    DMZMQ_ASSERT(n == 3);
    DMZMQ_ASSERT(zmq_ctx != NULL);

    void *zmq_sock = dmzmq_get_sock(atoi(v[0]));
    DMZMQ_ASSERT(zmq_sock != NULL);
   
    int option = atoi(v[1]);
    if(array_search_int(int64_sockopts, option, DMZMQ_INT64_SOCKOPT_COUNT))
    {
        int64_t value = atoll(v[2]);
        if(zmq_setsockopt(zmq_sock, option, &value, sizeof(value)) == -1)
        {
            return dmzmq_strerrno();
        }
    }
    else if(array_search_int(int_sockopts, option, DMZMQ_INT_SOCKOPT_COUNT))
    {
        int value = atoi(v[2]);
        if(zmq_setsockopt(zmq_sock, option, &value, sizeof(value)) == -1)
        {
            return dmzmq_strerrno();
        }
    }
    else if(array_search_int(str_sockopts, option, DMZMQ_STR_SOCKOPT_COUNT))
    {
        if(zmq_setsockopt(zmq_sock, option, v[2], strlen(v[2])) == -1)
        {
            return dmzmq_strerrno();
        }
    }
    else
    {
        return "ERR:_NOSUCHSOCKOPT";
    }
    return "";
}

DLL_EXPORT char *dmzmq_getsockopt(int n, char **v)
{
    DMZMQ_ASSERT(n == 2 || n == 3);
    DMZMQ_ASSERT(zmq_ctx != NULL);

    void *zmq_sock = dmzmq_get_sock(atoi(v[0]));
    DMZMQ_ASSERT(zmq_sock != NULL);

    sprintf(return_buf, "VAL:");
    size_t option_len;

    char *rbuf_ptr = return_buf + 4;

    int option = atoi(v[1]);
    if(array_search_int(int64_sockopts, option, DMZMQ_INT64_SOCKOPT_COUNT))
    {
        int64_t value;
        size_t value_size = sizeof(value);
        if(zmq_getsockopt(zmq_sock, option, &value, &value_size) == -1)
        {
            return dmzmq_strerrno();
        }
        sprintf(return_buf + 4, "%"PRIu64, value);
    }
    else if(array_search_int(int_sockopts, option, DMZMQ_INT_SOCKOPT_COUNT))
    {
        int value;
        size_t value_size = sizeof(value);
        if(zmq_getsockopt(zmq_sock, option, &value, &value_size) == -1)
        {
            return dmzmq_strerrno();
        }
        sprintf(return_buf + 4, "%d", value);
    }
    else if(array_search_int(str_sockopts, option, DMZMQ_STR_SOCKOPT_COUNT))
    {
        option_len = DMZMQ_RBUF_SIZE - 5;
        if(zmq_getsockopt(zmq_sock, option, rbuf_ptr, &option_len) == -1)
        {
            return dmzmq_strerrno();
        }
        rbuf_ptr[option_len] = '\0';
    }
    else
    {
        return "ERR:_NOSUCHSOCKOPT";
    }
    return return_buf;
}

void *dmzmq_get_sock(int sock_id)
{
    return dmzmq_socks[sock_id];
}
