#ifndef DMZMQ_SOCKET_H
#define DMZMQ_SOCKET_H

#include "base.h"

void dmzmq_socket_setup();
void dmzmq_socket_shutdown();

DLL_EXPORT char *dmzmq_socket(int n, char **v);
DLL_EXPORT char *dmzmq_close(int n, char **v);

DLL_EXPORT char *dmzmq_connect(int n, char **v);
DLL_EXPORT char *dmzmq_bind(int n, char **v);

DLL_EXPORT char *dmzmq_send(int n, char **v);
DLL_EXPORT char *dmzmq_recv(int n, char **v);

DLL_EXPORT char *dmzmq_setsockopt(int n, char **v);
DLL_EXPORT char *dmzmq_getsockopt(int n, char **v);

void *dmzmq_get_sock(int sock_id);

#endif//DMZMQ_SOCKET_H
