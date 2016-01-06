/proc/dmzmq_setup()
	var/ret = _dmzmq_setup(0)
	_DMZMQ_HANDLE_ERR(ret)

	ASSERT(ret == "API:[DMZMQ_API_VERSION]")

/proc/dmzmq_shutdown()
	var/ret = _dmzmq_shutdown(0)
	_DMZMQ_HANDLE_ERR(ret)
