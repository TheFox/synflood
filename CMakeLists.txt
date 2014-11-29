cmake_minimum_required(VERSION 2.6)
project(SynFlood)

set(SynFlood_VERSION_MAJOR 2)
set(SynFlood_VERSION_MINOR 0)
set(SynFlood_VERSION_PATCH 2)

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/bin)

execute_process(COMMAND libnet-config --defines OUTPUT_VARIABLE LIBNET_DEFINES OUTPUT_STRIP_TRAILING_WHITESPACE)
execute_process(COMMAND libnet-config --cflags OUTPUT_VARIABLE LIBNET_CFLAGS OUTPUT_STRIP_TRAILING_WHITESPACE)
execute_process(COMMAND libnet-config --libs OUTPUT_VARIABLE LIBNET_LIBS OUTPUT_STRIP_TRAILING_WHITESPACE)

configure_file("${PROJECT_SOURCE_DIR}/src/config.h.in" "${PROJECT_SOURCE_DIR}/src/config.h")

file(GLOB_RECURSE SynFlood_SOURCES "src/*.c")
file(GLOB_RECURSE SynFlood_HEADERS "src/*.h")

find_path(STDIO_INCLUDE_PATH stdio.h)
find_path(LIBNET_INCLUDE_PATH libnet.h)

set(SynFlood_INCLUDE_DIRS "")
foreach(_headerFile ${SynFlood_HEADERS})
	get_filename_component(_dir ${_headerFile} PATH)
	list(APPEND SynFlood_INCLUDE_DIRS ${_dir})
endforeach()
list(REMOVE_DUPLICATES SynFlood_INCLUDE_DIRS)

include_directories(${PROJECT_SOURCE_DIR})
include_directories(${SynFlood_INCLUDE_DIRS})
include_directories(${STDIO_INCLUDE_PATH})
include_directories(${LIBNET_INCLUDE_PATH})

add_definitions(-Wall)
add_definitions(-O3)

add_executable(synflood ${SynFlood_SOURCES})
target_link_libraries(synflood m)
target_link_libraries(synflood ${LIBNET_LIBS})

add_executable(synflood_test tests/synflood_test.c)
target_link_libraries(synflood_test m)
target_link_libraries(synflood_test ${LIBNET_LIBS})



enable_testing()

add_test(NAME StdRuns COMMAND synflood)
set_tests_properties(StdRuns PROPERTIES WILL_FAIL true)

add_test(NAME TestRuns COMMAND synflood_test)


MESSAGE("")

MESSAGE(STATUS "PROJECT_NAME: ${PROJECT_NAME}")
MESSAGE(STATUS "PROJECT_SOURCE_DIR: ${PROJECT_SOURCE_DIR}")
MESSAGE(STATUS "PROJECT_BINARY_DIR: ${PROJECT_BINARY_DIR}")
MESSAGE("")

MESSAGE(STATUS "CMAKE_C_COMPILER: ${CMAKE_C_COMPILER}")
MESSAGE(STATUS "CMAKE_C_FLAGS: ${CMAKE_C_FLAGS}")
MESSAGE(STATUS "CMAKE_SHARED_LINKER_FLAGS: ${CMAKE_SHARED_LINKER_FLAGS}")
MESSAGE(STATUS "CMAKE_INCLUDE_PATH: ${CMAKE_INCLUDE_PATH}")
MESSAGE(STATUS "CMAKE_LIBRARY_PATH: ${CMAKE_LIBRARY_PATH}")
MESSAGE(STATUS "STDIO_INCLUDE_PATH: ${STDIO_INCLUDE_PATH}")
MESSAGE("")

MESSAGE(STATUS "LIBNET_DEFINES: ${LIBNET_DEFINES}")
MESSAGE(STATUS "LIBNET_CFLAGS: ${LIBNET_CFLAGS}")
MESSAGE(STATUS "LIBNET_LIBS: ${LIBNET_LIBS}")
MESSAGE(STATUS "LIBNET_INCLUDE_PATH: ${LIBNET_INCLUDE_PATH}")
MESSAGE("")

MESSAGE(STATUS "SynFlood_SOURCES: ${SynFlood_SOURCES}")
MESSAGE(STATUS "SynFlood_HEADERS: ${SynFlood_HEADERS}")
MESSAGE(STATUS "SynFlood_INCLUDE_DIRS: ${SynFlood_INCLUDE_DIRS}")
MESSAGE("")
