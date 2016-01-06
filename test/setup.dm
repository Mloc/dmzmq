SUITE(dmZMQ)
	FIXTURE(EnsureCleanState)
		fixture_destroy()
			try
				dmzmq_shutdown()
			catch(var/exception/dmzmq_error/e)
				if(!istype(e))
					throw(e)

	TEST_FIXTURE(EnsureCleanState, ContextSetupShutdown)
		dmzmq_setup()
		dmzmq_shutdown()
	
	TEST_FIXTURE(EnsureCleanState, ContextDoubleSetup)
		dmzmq_setup()
		CHECK_THROW(/exception/dmzmq_error, dmzmq_setup())
	
	TEST_FIXTURE(EnsureCleanState, ContextDoubleShutdown)
		dmzmq_setup()
		dmzmq_shutdown()
		CHECK_THROW(/exception/dmzmq_error, dmzmq_shutdown())
	
	TEST_FIXTURE(EnsureCleanState, ContextShutdownNoSetup)
		CHECK_THROW(/exception/dmzmq_error, dmzmq_shutdown())
	
	TEST_FIXTURE(EnsureCleanState, BasicSocket)
		dmzmq_setup()
		var/datum/zmq_socket/sock = new(ZMQ_REQ)
		sock.close()
		dmzmq_shutdown()
	
	TEST_FIXTURE(EnsureCleanState, SocketNoContext)
		CHECK_THROW(/exception/dmzmq_error, var/datum/zmq_socket/sock = new(ZMQ_REQ); sock.close())
	
	TEST_FIXTURE(EnsureCleanState, SocketClosedContext)
		dmzmq_setup()
		var/datum/zmq_socket/sock = new(ZMQ_REQ)
		dmzmq_shutdown()
		CHECK_THROW(/exception/dmzmq_error, sock.close())	
