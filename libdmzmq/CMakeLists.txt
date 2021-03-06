cmake_minimum_required(VERSION 2.8)
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake-modules")

project(dmzmq)

find_package(ZMQ REQUIRED)

include_directories(
    "${ZMQ_INCLUDE_DIRS}"
)

set(dmzmq_SOURCES
    src/base.c
    src/dmzmq.c
    src/socket.c
    src/polling.c
    src/murmurhash.c
    src/cache_table.c
)

set(dmzmq_LIBS
    "${ZMQ_LIBRARIES}"
)

add_library(dmzmq SHARED ${dmzmq_SOURCES})
target_link_libraries(dmzmq ${dmzmq_LIBS})
if(UNIX)
    set_target_properties(dmzmq PROPERTIES COMPILE_FLAGS "-m32" LINK_FLAGS "-m32")
endif()
