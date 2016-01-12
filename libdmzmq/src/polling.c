#include "polling.h"

#include "base.h"
#include "config.h"
#include "dmzmq.h"
#include "socket.h"
#include "cache_table.h"

#include <zmq.h>
#include <stdlib.h>
#include <string.h>

// working pollset, set by dmzmq_pollread and read by dmzmq_pollnext

int work_index;

// cache table for generated poll lists
ct_table *poll_cache;

void dmzmq_free_pollset(void *data)
{
    dmzmq_pollset *pollset = data;
    free(pollset->items);
    free(data);
}

dmzmq_pollset *dmzmq_parse_pollset(const char *poll_str)
{
    size_t len = strlen(poll_str);
    dmzmq_pollset *pollset = ct_get(poll_cache, poll_str, len);
    if(pollset == NULL)
    {
        int sockets = 1;

        int i;
        for(i = 0; i < len; i++)
        {
            if(poll_str[i] == '&')
            {
                sockets++;
            }
        }

        zmq_pollitem_t *items = malloc(sockets * sizeof(zmq_pollitem_t));
        int *socket_ids = malloc(sockets * sizeof(int));
        pollset = malloc(sizeof(zmq_pollitem_t));
        pollset->items = items;
        pollset->socket_ids = socket_ids;
        pollset->size = sockets;

        int num_start = 1;
        int poll_i = 0;
        for(i = 0; i < len; i++)
        {
            if(poll_str[i] == '&')
            {
                num_start = 1;
            }
            else if(num_start)
            {
                int sock_id = atoi(poll_str + i);
                socket_ids[poll_i] = sock_id;
                items[poll_i].socket = dmzmq_get_sock(sock_id);
                items[poll_i].events = ZMQ_POLLIN;
                poll_i++;
                num_start = 0;
            }
        }

        ct_put(poll_cache, poll_str, len, pollset);
    }

    return pollset;
}

void dmzmq_polling_setup()
{
    poll_cache = ct_init(DMZMQ_POLLCACHE_SIZE, dmzmq_free_pollset);
}

void dmzmq_polling_shutdown()
{
    ct_free(poll_cache);
}

DLL_EXPORT char *dmzmq_pollread(int n, char **v)
{
    DMZMQ_ASSERT(n == 1);
    DMZMQ_ASSERT(zmq_ctx != NULL);

    dmzmq_pollset *work_pollset = dmzmq_parse_pollset(v[0]);
    int ret = zmq_poll(work_pollset->items, work_pollset->size, 0);

    if(ret == -1)
    {
        return dmzmq_strerrno();
    }

    if(ret == 0)
    {
        return "RES:";
    }
    sprintf(return_buf, "RES:");
    char *rbuf_pointer = return_buf + 4;

    size_t size = work_pollset->size;
    int i;
    for(i = 0; i < size; i++)
    {
        if(work_pollset->items[i].revents & ZMQ_POLLIN)
        {
            rbuf_pointer += sprintf(rbuf_pointer, "%d;",
                                    work_pollset->socket_ids[i]);
        }
    }
    return return_buf;
}
