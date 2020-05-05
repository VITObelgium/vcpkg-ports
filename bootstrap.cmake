find_package(Git)

set(VCPKG_TAG "2020.04")
set(BUILD_DIR ${CMAKE_CURRENT_LIST_DIR}/buildtrees)
set(BIN_DIR ${CMAKE_CURRENT_LIST_DIR}/bin)
set(VCPKG_BUILD_DIR ${BUILD_DIR}/vcpkg)

file(MAKE_DIRECTORY ${BUILD_DIR} ${BIN_DIR})
file(REMOVE_RECURSE ${VCPKG_BUILD_DIR})

if (WIN32 AND NOT MINGW)
    set(SCRIPT_EXTENSION ".bat")
else ()
    set(SCRIPT_EXTENSION ".sh")
endif ()

execute_process(
    COMMAND ${GIT_EXECUTABLE} -c advice.detachedHead=false clone --branch ${VCPKG_TAG} https://github.com/microsoft/vcpkg.git
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
    COMMAND ${VCPKG_BUILD_DIR}/bootstrap-vcpkg${SCRIPT_EXTENSION} -disableMetrics
    WORKING_DIRECTORY ${VCPKG_BUILD_DIR}
    RESULT_VARIABLE CMD_ERROR
)

if (CMD_ERROR)
    message(FATAL_ERROR "Failed to bootstrap vcpkg (Error: ${CMD_ERROR})")
endif ()

find_program(VCPKG_PATH vcpkg PATHS ${VCPKG_BUILD_DIR} NO_DEFAULT_PATH)
if (NOT VCPKG_PATH)
    message(FATAL_ERROR "Could not find vcpkg binary")
endif ()

file(COPY ${VCPKG_PATH} DESTINATION ${BIN_DIR})
message(STATUS "Vcpkg installed in ${BIN_DIR}")