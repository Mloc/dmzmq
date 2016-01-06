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

/datum/zmq_socket/proc/send(data)
	var/ret = _dmzmq_send(_zmq_sock, data)
	_DMZMQ_HANDLE_ERR(ret)

/datum/zmq_socket/proc/recv()
	var/ret = _dmzmq_recv(_zmq_sock)
	_DMZMQ_HANDLE_ERR(ret)

	return copytext(ret, 5, 0)

/datum/zmq_socket/proc/subscribe(filter)
	var/ret = _dmzmq_subscribe(_zmq_sock, filter)
	_DMZMQ_HANDLE_ERR(ret)
