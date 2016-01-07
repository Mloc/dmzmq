/datum/zmq_pollset/test_tally
	var/tally = 0

/datum/zmq_pollset/test_tally/empoll()
	tally++
	return ..()

/datum/zmq_pollset/test_tally/on_msg(sock, msg)
	tally--


/datum/zmq_socket/callback/test_markoff
	var/marks = 0

/datum/zmq_socket/callback/test_markoff/on_msg(msg)
	marks++


SUITE(dmZMQ)
	FIXTURE(dmZMQSetup)
		fixture_setup()
			dmzmq_setup()

		fixture_destroy()
			dmzmq_shutdown()
	
	TEST_FIXTURE(dmZMQSetup, BasicPushPull)
		var/datum/zmq_socket/push_sock = new(ZMQ_PUSH)
		var/datum/zmq_socket/pull_sock = new(ZMQ_PULL)

		pull_sock.bind("inproc://test")
		push_sock.connect("inproc://test")

		push_sock.send("hello, world!")
		CHECK(pull_sock.recv() == "hello, world!")
	
	TEST_FIXTURE(dmZMQSetup, PubSubPoll)
		var/datum/zmq_socket/pub_sock = new(ZMQ_PUB)
		pub_sock.bind("inproc://test")

		var/datum/zmq_pollset/test_tally/pollset = new
		for(var/i = 1 to 64)
			var/datum/zmq_socket/sub_sock = new(ZMQ_SUB)
			sub_sock.connect("inproc://test")
			sub_sock.subscribe("hello")
			pollset.empoll(sub_sock)
		
		pub_sock.send("hello, world!")
		pollset.poll()

		CHECK(pollset.tally == 0)
	
	TEST_FIXTURE(dmZMQSetup, PushPullCallback)
		var/datum/zmq_socket/push_sock = new(ZMQ_PUSH)
		push_sock.bind("inproc://test")

		var/list/socks = list()
		for(var/i = 1 to 64)
			var/datum/zmq_socket/callback/test_markoff/sock = new(ZMQ_PULL)
			sock.connect("inproc://test")
			socks += sock

		for(var/i = 1 to 64)
			push_sock.send("hello, world!")

		callback_socket_pollset.poll()
		for(var/datum/zmq_socket/callback/test_markoff/sock in socks)
			CHECK(sock.marks == 1)

		for(var/i = 1 to 64 * 15)
			push_sock.send("hello, world!")

		callback_socket_pollset.poll()
		for(var/datum/zmq_socket/callback/test_markoff/sock in socks)
			CHECK(sock.marks == 16)

		for(var/datum/zmq_socket/callback/test_markoff/sock in socks)
			sock.close()
