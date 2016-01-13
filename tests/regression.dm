SUITE(dmZMQ)
	TEST_FIXTURE(dmZMQSetup, RegressionEmptyPoll)
		var/datum/zmq_pollset/pollset = new
		pollset.poll()
