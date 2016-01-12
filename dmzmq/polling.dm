/datum/zmq_pollset
	var/list/sock_ids = list() // regular list of sock_ids, run through list2params
	var/list/sock_datums = list() // assoc list, sock_id -> datum

	var/_needs_update = 1
	var/_poll_str = ""

// list maintenance
/datum/zmq_pollset/proc/empoll(datum/zmq_socket/socket)
	sock_ids |= socket._zmq_sock
	sock_datums[socket._zmq_sock] = socket
	_needs_update = 1

/datum/zmq_pollset/proc/depoll(datum/zmq_socket/socket)
	sock_ids -= socket._zmq_sock
	sock_datums -= socket._zmq_sock
	_needs_update = 1

// actual polling
/datum/zmq_pollset/proc/poll()
	if(_needs_update)
		_poll_str = list2params(sock_ids)
		_needs_update = 0

	var/ret = _dmzmq_pollread(_poll_str)
	_DMZMQ_HANDLE_ERR(ret)

	var/list/sds = params2list(copytext(ret, 5, 0))

	for(var/sd in sds)
		on_readable(sock_datums[sd])

/datum/zmq_pollset/proc/on_readable(datum/zmq_socket/sock)
	while(1)
		var/msg = sock.recv(ZMQ_DONTWAIT)
		if(msg == -2) // EAGAIN
			break

		on_msg(sock, msg)

// hookable callback for messages
/datum/zmq_pollset/proc/on_msg(datum/zmq_socket/sock, msg)
