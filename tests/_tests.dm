#ifdef TESTING
#define DEBUG

#include "setup.dm"
#include "socket.dm"
#include "regression.dm"

/world/New()
	. = ..()

	var/datum/dmut_manager/test_manager = new
	test_manager.run_tests()
	del(src)

#endif
