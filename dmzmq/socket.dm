/datum/zmq_socket
	var/sock_type
	var/_zmq_sock = null

/datum/zmq_socket/New(new_sock_type)
	var/ret = _dmzmq_socket(new_sock_type)
	_DMZMQ_HANDLE_ERR(ret)

	sock_type = new_sock_type
	_zmq_sock = copytext(ret, 5, 0)

/datum/zmq_socket/Del()
	close()
	return ..()

/datum/zmq_socket/proc/close()
	if(_zmq_sock)
		var/ret = _dmzmq_close(_zmq_sock)
		_zmq_sock = null
		_DMZMQ_HANDLE_ERR(ret)

/datum/zmq_socket/proc/connect(endpoint)
	var/ret = _dmzmq_connect(_zmq_sock, endpoint)
	_DMZMQ_HANDLE_ERR(ret)

/datum/zmq_socket/proc/bind(endpoint)
	var/ret = _dmzmq_bind(_zmq_sock, endpoint)
	_DMZMQ_HANDLE_ERR(ret)

/datum/zmq_socket/proc/send(data, flags = 0)
	var/ret = _dmzmq_send(_zmq_sock, data, flags)
	_DMZMQ_HANDLE_ERR(ret)

/datum/zmq_socket/proc/recv(flags = 0)
	var/ret = _dmzmq_recv(_zmq_sock, flags)
	if(ret == "ERR:EAGAIN")
		return -2
	_DMZMQ_HANDLE_ERR(ret)

	return copytext(ret, 5, 0)

/datum/zmq_socket/proc/send_multi(list/msg)
	for(var/i = 1; i < msg.len; i++)
		send(msg[i], ZMQ_SNDMORE)
	send(msg[msg.len])

/datum/zmq_socket/proc/recv_multi(flags = 0)
	var/list/msg = list()
	var/ret = recv(flags)
	if(ret == -2)
		return ret
	msg += ret
	while(getsockopt(ZMQ_RCVMORE) == "1")
		msg += recv(flags)
	return msg

/datum/zmq_socket/proc/setsockopt(opt, value)
	var/ret = _dmzmq_setsockopt(_zmq_sock, opt, value)
	_DMZMQ_HANDLE_ERR(ret)

/datum/zmq_socket/proc/getsockopt(opt)
	var/ret = _dmzmq_getsockopt(_zmq_sock, opt)
	_DMZMQ_HANDLE_ERR(ret)

	return copytext(ret, 5, 0)
