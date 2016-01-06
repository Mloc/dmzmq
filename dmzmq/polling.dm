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

	if(ret != "END")
		while(1)
			ret = _dmzmq_pollnext(0)
			_DMZMQ_HANDLE_ERR(ret)

			if(ret == "END")
				break

			ASSERT(copytext(ret, 1, 4) == "MSG")
			var/msgstart = findtext(ret, ":", 5)
			ASSERT(msgstart)

			var/sock_id = copytext(ret, 5, msgstart)
			var/message = copytext(ret, msgstart + 1)

			on_msg(sock_datums[sock_id], message)

// hookable callback for messages
/datum/zmq_pollset/proc/on_msg(socket, msg)
