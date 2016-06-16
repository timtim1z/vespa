# Copyright 2016 Yahoo Inc. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.
# @author Vegard Sjonfjell

include(vtag.cmake)

# Build options
# Whether to build unit tests as part of the 'all' target
set(EXCLUDE_TESTS_FROM_ALL FALSE CACHE BOOL "If TRUE, do not build tests as part of the 'all' target")

# Whether to run unit tests via valgrind
set(VALGRIND_UNIT_TESTS FALSE CACHE BOOL "If TRUE, run unit tests via valgrind")

# Warnings
set(WARN_OPTS "-Wuninitialized -Werror -Wall -W -Wchar-subscripts -Wcomment -Wformat -Wparentheses -Wreturn-type -Wswitch -Wtrigraphs -Wunused -Wshadow -Wpointer-arith -Wcast-qual -Wcast-align -Wwrite-strings")

# C and C++ compiler flags
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -g -O3 ${WARN_OPTS} -fPIC -D_GLIBCXX_USE_CXX11_ABI=0 -DBOOST_DISABLE_ASSERTS -DWITH_SHIPPED_GEOIP -march=westmere -mtune=intel")

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${VTAG_DEFINES}")

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${CMAKE_C_FLAGS} -Wnon-virtual-dtor -fvisibility-inlines-hidden -fdiagnostics-color=auto")

# Linker flags
set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Wl,--build-id -latomic -ldl -Wl,-E")

# Use C++ 14
set(CMAKE_CXX_STANDARD 14)

# Always build shared libs if not explicitly specified
set(BUILD_SHARED_LIBS ON)

set(CMAKE_THREAD_PREFER_PTHREAD TRUE)

# Default RPATH settings for CMake 3.4:
# For non-installed targets, reference external libraries using an RPATH into the build tree.
# For installed targets, reference external libraries using INSTALL_RPATH (i.e. /home/y/lib64 on ylinux)
set(CMAKE_CMAKE_SKIP_BUILD_RPATH FALSE)
set(CMAKE_BUILD_WITH_INSTALL_RPATH FALSE)
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH FALSE)

# OS X Stuff
if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Darwin")
    set(MACOSX_RPATH ON)

    if(__COMPILER_GNU)
        SET(CMAKE_INCLUDE_SYSTEM_FLAG_C "-isystem ")
        SET(CMAKE_INCLUDE_SYSTEM_FLAG_CXX "-isystem ")
    endif()
endif()

# Find ccache and use it if it is found
find_program(CCACHE_EXECUTABLE ccache)
if(CCACHE_EXECUTABLE)
    set_property(GLOBAL PROPERTY RULE_LAUNCH_COMPILE ${CCACHE_EXECUTABLE})
    set_property(GLOBAL PROPERTY RULE_LAUNCH_LINK ${CCACHE_EXECUTABLE})
endif()

# Check for valgrind and set flags
find_program(VALGRIND_EXECUTABLE valgrind)
if(VALGRIND_EXECUTABLE)
    set(VALGRIND_SUPPRESSIONS_FILE "${PROJECT_SOURCE_DIR}/valgrind-suppressions.txt")
    set(VALGRIND_OPTIONS "--leak-check=yes --error-exitcode=1 --run-libc-freeres=no --track-origins=yes --suppressions=${VALGRIND_SUPPRESSIONS_FILE}")
    set(VALGRIND_COMMAND "${VALGRIND_EXECUTABLE} ${VALGRIND_OPTIONS}")
endif()

if(EXTRA_LINK_DIRECTORY)
    link_directories(${EXTRA_LINK_DIRECTORY})
endif()
set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Wl,-rpath,${CMAKE_BUILD_RPATH}")
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Wl,-rpath,${CMAKE_BUILD_RPATH}")
