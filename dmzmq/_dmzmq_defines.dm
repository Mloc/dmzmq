#define DMZMQ_API_VERSION "0.1.0"

#ifndef _DMZMQ_SO
	#define _DMZMQ_SO "libdmzmq.so"
#endif

#define _DMZMQ_SOCALL(zcall) call(_DMZMQ_SO, zcall)

#define _dmzmq_setup(_) _DMZMQ_SOCALL("dmzmq_setup")()
#define _dmzmq_shutdown(_) _DMZMQ_SOCALL("dmzmq_shutdown")()

#define _dmzmq_socket(sock_type) _DMZMQ_SOCALL("dmzmq_socket")("[sock_type]")
#define _dmzmq_close(sock) _DMZMQ_SOCALL("dmzmq_close")(sock)

#define _dmzmq_connect(sock, endpoint) _DMZMQ_SOCALL("dmzmq_connect")(sock, endpoint)
#define _dmzmq_bind(sock, endpoint) _DMZMQ_SOCALL("dmzmq_bind")(sock, endpoint)

#define _dmzmq_setsockopt(sock, opt, value) _DMZMQ_SOCALL("dmzmq_setsockopt")(sock, "[opt]", "[value]")
#define _dmzmq_getsockopt(sock, opt) _DMZMQ_SOCALL("dmzmq_getsockopt")(sock, "[opt]")

#define _dmzmq_send(sock, data, flags) _DMZMQ_SOCALL("dmzmq_send")(sock, data, "[flags]")
#define _dmzmq_recv(sock, flags) _DMZMQ_SOCALL("dmzmq_recv")(sock, "[flags]")

#define _dmzmq_pollread(pollset) _DMZMQ_SOCALL("dmzmq_pollread")(pollset)

/exception/dmzmq_error
#define _DMZMQ_HANDLE_ERR(str) if(copytext(str, 1, 4) == "ERR") { throw new /exception/dmzmq_error(copytext(str, 5, 0), __FILE__, __LINE__) }
