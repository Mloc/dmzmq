/var/datum/zmq_pollset/callback_sockets/callback_socket_pollset = new

/datum/zmq_socket/callback/New()
	. = ..()
	callback_socket_pollset.empoll(src)

/datum/zmq_socket/callback/close()
	callback_socket_pollset.depoll(src)
	return ..()

/datum/zmq_socket/callback/proc/on_msg(msg)

/datum/zmq_pollset/callback_sockets/on_msg(socket, msg)
	var/datum/zmq_socket/callback/callback_socket = socket
	ASSERT(istype(callback_socket))
	callback_socket.on_msg(msg)
