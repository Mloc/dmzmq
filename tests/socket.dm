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

	TEST_FIXTURE(dmZMQSetup, BasicReqRep)
		var/datum/zmq_socket/req_sock = new(ZMQ_REQ)
		var/datum/zmq_socket/rep_sock = new(ZMQ_REP)

		rep_sock.bind("inproc://test")
		req_sock.connect("inproc://test")

		req_sock.send("ping")
		CHECK(rep_sock.recv() == "ping")

		rep_sock.send("pong")
		CHECK(req_sock.recv() == "pong")
	
	TEST_FIXTURE(dmZMQSetup, BasicPubSub)
		var/datum/zmq_socket/pub_sock = new(ZMQ_PUB)
		var/datum/zmq_socket/sub_sock_1 = new(ZMQ_SUB)
		var/datum/zmq_socket/sub_sock_2 = new(ZMQ_SUB)

		pub_sock.bind("inproc://test")
		sub_sock_1.connect("inproc://test")
		sub_sock_2.connect("inproc://test")

		sub_sock_1.setsockopt(ZMQ_SUBSCRIBE, "test1")
		sub_sock_2.setsockopt(ZMQ_SUBSCRIBE, "test2")

		pub_sock.send("test1 foo")
		pub_sock.send("test2 bar")

		CHECK(sub_sock_2.recv() == "test2 bar")
		CHECK(sub_sock_1.recv() == "test1 foo")

	TEST_FIXTURE(dmZMQSetup, BasicPushPull)
		var/datum/zmq_socket/push_sock = new(ZMQ_PUSH)
		var/datum/zmq_socket/pull_sock = new(ZMQ_PULL)

		pull_sock.bind("inproc://test")
		push_sock.connect("inproc://test")

		push_sock.send("hello, world!")
		CHECK(pull_sock.recv() == "hello, world!")
	
	TEST_FIXTURE(dmZMQSetup, MultipartReqRep)
		var/datum/zmq_socket/req_sock = new(ZMQ_REQ)
		var/datum/zmq_socket/rep_sock = new(ZMQ_REP)
		
		rep_sock.bind("inproc://test")
		req_sock.connect("inproc://test")

		req_sock.send_multi(params2list("abc;def;foo;bar"))

		CHECK_LIST_EQUAL(rep_sock.recv_multi(), list("abc", "def", "foo", "bar"))
	
	TEST_FIXTURE(dmZMQSetup, PubSubPoll)
		var/datum/zmq_socket/pub_sock = new(ZMQ_PUB)
		pub_sock.bind("inproc://test")

		var/datum/zmq_pollset/test_tally/pollset = new
		for(var/i = 1 to 64)
			var/datum/zmq_socket/sub_sock = new(ZMQ_SUB)
			sub_sock.connect("inproc://test")
			sub_sock.setsockopt(ZMQ_SUBSCRIBE, "hello")
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
	
	TEST_FIXTURE(dmZMQSetup, GetBindEndpoint)
		var/datum/zmq_socket/sock = new(ZMQ_REP)
		sock.bind("inproc://abcfoo")
		CHECK(sock.getsockopt(ZMQ_LAST_ENDPOINT) == "inproc://abcfoo")
