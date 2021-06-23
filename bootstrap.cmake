find_package(Git)

set(VCPKG_TAG "2021-05-05-9f849c4c43e50d1b16186ae76681c27b0c1be9d9")
set(BUILD_DIR ${CMAKE_CURRENT_LIST_DIR}/buildtrees)
set(BIN_DIR ${CMAKE_CURRENT_LIST_DIR})
set(VCPKG_BUILD_DIR ${BUILD_DIR}/vcpkg-tool)
set(VCPKG_BUILD_OUTPUT ${VCPKG_BUILD_DIR}/build)

file(MAKE_DIRECTORY ${BUILD_DIR} ${BIN_DIR})
file(REMOVE_RECURSE ${VCPKG_BUILD_DIR})

if (WIN32)
    set(GENERATOR "Visual Studio 16 2019")
    set(CONFIG_ARGS -A x64 -DCMAKE_CXX_FLAGS=/MP)
    set(BUILD_ARGS --config Release)
else ()
    set(GENERATOR Ninja)
endif ()

execute_process(
    COMMAND ${GIT_EXECUTABLE} -c advice.detachedHead=false clone --depth 1 --quiet --branch ${VCPKG_TAG} https://github.com/microsoft/vcpkg-tool.git
    WORKING_DIRECTORY ${BUILD_DIR}
    RESULT_VARIABLE CMD_ERROR
)
if (CMD_ERROR)
    message(FATAL_ERROR "Failed to clone vcpkg tag ${VCPKG_TAG} (Error: ${CMD_ERROR})")
endif ()

execute_process(
    COMMAND ${GIT_EXECUTABLE} --work-tree=. --git-dir=.git apply ${CMAKE_CURRENT_LIST_DIR}/vcpkg-llvm.patch --ignore-whitespace --whitespace=nowarn --verbose
    WORKING_DIRECTORY ${VCPKG_BUILD_DIR}
    RESULT_VARIABLE CMD_ERROR
)
if (CMD_ERROR)
    message(FATAL_ERROR "Failed to apply vcpkg patch (Error: ${CMD_ERROR})")
endif ()

execute_process(
    COMMAND cmake -G ${GENERATOR} ${CONFIG_ARGS} -DCMAKE_BUILD_TYPE=Release -DVCPKG_ALLOW_APPLE_CLANG=ON -DBUILD_TESTING=OFF -S ${VCPKG_BUILD_DIR} -B ${VCPKG_BUILD_OUTPUT}
    RESULT_VARIABLE CMD_ERROR
)

if (CMD_ERROR)
    message(FATAL_ERROR "Failed to configure vcpkg (Error: ${CMD_ERROR})")
endif ()

execute_process(
    COMMAND cmake --build ${VCPKG_BUILD_OUTPUT} ${BUILD_ARGS}
    RESULT_VARIABLE CMD_ERROR
)

if (CMD_ERROR)
    message(FATAL_ERROR "Failed to build vcpkg (Error: ${CMD_ERROR})")
endif ()

find_program(VCPKG_PATH vcpkg PATHS ${VCPKG_BUILD_OUTPUT} PATH_SUFFIXES Release NO_DEFAULT_PATH)
if (NOT VCPKG_PATH)
    message(FATAL_ERROR "Could not find vcpkg binary")
endif ()

file(COPY ${VCPKG_PATH} DESTINATION ${BIN_DIR})
message(STATUS "Vcpkg installed in ${BIN_DIR}")