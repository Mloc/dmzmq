#define DMZMQ_API_VERSION "0.1.0"

#define ZMQ_PAIR "a"
#define ZMQ_PUB "b"
#define ZMQ_SUB "c"
#define ZMQ_REQ "d"
#define ZMQ_REP "e"
#define ZMQ_DEALER "f"
#define ZMQ_ROUTER "g"
#define ZMQ_PULL "h"
#define ZMQ_PUSH "i"
#define ZMQ_XPUB "j"
#define ZMQ_XSUB "k"
#define ZMQ_STREAM "l"

#ifndef _DMZMQ_SO
	#define _DMZMQ_SO "libdmzmq.so"
#endif

#define _DMZMQ_SOCALL(zcall) call(_DMZMQ_SO, zcall)

#define _dmzmq_setup(_) _DMZMQ_SOCALL("dmzmq_setup")()
#define _dmzmq_shutdown(_) _DMZMQ_SOCALL("dmzmq_shutdown")()

#define _dmzmq_socket(sock_type) _DMZMQ_SOCALL("dmzmq_socket")(sock_type)
#define _dmzmq_close(sock) _DMZMQ_SOCALL("dmzmq_close")(sock)

#define _dmzmq_connect(sock, endpoint) _DMZMQ_SOCALL("dmzmq_connect")(sock, endpoint)
#define _dmzmq_bind(sock, endpoint) _DMZMQ_SOCALL("dmzmq_bind")(sock, endpoint)

#define _dmzmq_subscribe(sock, filter) _DMZMQ_SOCALL("dmzmq_subscribe")(sock, filter)

#define _dmzmq_send(sock, data) _DMZMQ_SOCALL("dmzmq_send")(sock, data)
#define _dmzmq_recv(sock) _DMZMQ_SOCALL("dmzmq_recv")(sock)

#define _dmzmq_pollread(pollset) _DMZMQ_SOCALL("dmzmq_pollread")(pollset)
#define _dmzmq_pollnext(_) _DMZMQ_SOCALL("dmzmq_pollnext")()

/exception/dmzmq_error
#define _DMZMQ_HANDLE_ERR(str) if(copytext(str, 1, 4) == "ERR") { throw new /exception/dmzmq_error(copytext(str, 5, 0), __FILE__, __LINE__) }
