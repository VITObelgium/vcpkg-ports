## # vcpkg_test_cmake
##
## Tests a built package for CMake `find_package()` integration.
##
## ## Usage:
## ```cmake
## vcpkg_test_cmake(PACKAGE_NAME <name> [MODULE])
## ```
##
## ## Parameters:
##
## ### PACKAGE_NAME
## The expected name to find with `find_package()`.
##
## ### MODULE
## Indicates that the library expects to be found via built-in CMake targets.
##
function(vcpkg_test_cmake)
    cmake_parse_arguments(_tc "MODULE" "PACKAGE_NAME;REQUIRED_HEADER" "TARGETS" ${ARGN})

    if(NOT DEFINED _tc_PACKAGE_NAME)
      message(FATAL_ERROR "PACKAGE_NAME must be specified")
    endif()
    if(_tc_MODULE)
      set(PACKAGE_TYPE MODULE)
    else()
      set(PACKAGE_TYPE CONFIG)
    endif()

    message(STATUS "Performing CMake integration test")
    file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-test)
    file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-test)

    # Generate test source CMakeLists.txt
    set(VCPKG_TEST_CMAKELIST ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-test/CMakeLists.txt)
    file(WRITE  ${VCPKG_TEST_CMAKELIST} "cmake_minimum_required(VERSION 3.15)\n")
    file(APPEND ${VCPKG_TEST_CMAKELIST} "project(cmaketestproject LANGUAGES CXX)\n")
    file(APPEND ${VCPKG_TEST_CMAKELIST} "set(CMAKE_PREFIX_PATH \"${CURRENT_PACKAGES_DIR};${CURRENT_INSTALLED_DIR}\")\n\n")
    file(APPEND ${VCPKG_TEST_CMAKELIST} "find_package(${_tc_PACKAGE_NAME} ${PACKAGE_TYPE} REQUIRED)\n")
    if(_tc_TARGETS OR _tc_REQUIRED_HEADER)
      file(APPEND ${VCPKG_TEST_CMAKELIST} "add_executable(cmaketest main.cpp)\n")
      if(_tc_TARGETS)
        file(APPEND ${VCPKG_TEST_CMAKELIST} "target_link_libraries(cmaketest PRIVATE ${_tc_TARGETS})\n")
      endif()

      set(VCPKG_TEST_MAIN ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-test/main.cpp)
      if (_tc_REQUIRED_HEADER)
        file(APPEND ${VCPKG_TEST_MAIN} "#include <${_tc_REQUIRED_HEADER}>\n")
      endif ()
      file(APPEND ${VCPKG_TEST_MAIN} "int main(int, char**) { return 0; }\n")
    endif ()

    if(VCPKG_TARGET_ARCHITECTURE MATCHES "x64" AND VCPKG_PLATFORM_TOOLSET MATCHES "v141")
      set(GENERATOR "Visual Studio 15 2017 Win64")
    elseif(VCPKG_TARGET_ARCHITECTURE MATCHES "x64" AND VCPKG_PLATFORM_TOOLSET MATCHES "v142")
      set(GENERATOR "Visual Studio 16 2019")
      set(ARCH -A ${VCPKG_TARGET_ARCHITECTURE})
    else ()
      vcpkg_find_acquire_program(NINJA)
      set(GENERATOR "Ninja")
      set(MAKE_PROGRAM_ARG -DCMAKE_MAKE_PROGRAM=${NINJA})
    endif ()

    # Run cmake config with a generated CMakeLists.txt
    set(LOGPREFIX "${CURRENT_BUILDTREES_DIR}/test-cmake-${TARGET_TRIPLET}")
    set(PREFIXES ${CURRENT_PACKAGES_DIR} ${CURRENT_PACKAGES_DIR}/debug)

    if(VCPKG_VERBOSE)
      message(STATUS "${CMAKE_COMMAND} -G ${GENERATOR} ${ARCH} ${MAKE_PROGRAM_ARG} -DCMAKE_TOOLCHAIN_FILE=${CMAKE_CURRENT_LIST_DIR}/../../scripts/buildsystems/vcpkg.cmake -DVCPKG_TARGET_TRIPLET=${TARGET_TRIPLET} -DVCPKG_APPLOCAL_DEPS=OFF -DCMAKE_FIND_ROOT_PATH=${CURRENT_PACKAGES_DIR} -DCMAKE_MODULE_PATH=${CURRENT_PACKAGES_DIR}/share/cmake;${CURRENT_INSTALLED_DIR}/share/cmake .")
    endif()

    execute_process(
      COMMAND ${CMAKE_COMMAND} -G ${GENERATOR} ${ARCH} ${MAKE_PROGRAM_ARG} -DCMAKE_TOOLCHAIN_FILE=${CMAKE_CURRENT_LIST_DIR}/../../scripts/buildsystems/vcpkg.cmake -DVCPKG_TARGET_TRIPLET=${TARGET_TRIPLET} -DVCPKG_APPLOCAL_DEPS=OFF -DCMAKE_FIND_ROOT_PATH=${CURRENT_PACKAGES_DIR} -DCMAKE_MODULE_PATH=${CURRENT_PACKAGES_DIR}/share/cmake;${CURRENT_INSTALLED_DIR}/share/cmake .
      OUTPUT_VARIABLE CONFIG_OUTPUT
      ERROR_VARIABLE CONFIG_OUTPUT
      RESULT_VARIABLE error_code
      WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-test
    )
    if(error_code)
      message(FATAL_ERROR "CMake integration test failed; unable to find_package(${_tc_PACKAGE_NAME} ${PACKAGE_TYPE} REQUIRED) (${CONFIG_OUTPUT})")
    endif()

    if(_tc_TARGETS OR _tc_REQUIRED_HEADER)
      execute_process(
        COMMAND ${CMAKE_COMMAND} --build . --config Release
        OUTPUT_VARIABLE BUILD_OUTPUT
        ERROR_VARIABLE BUILD_OUTPUT
        RESULT_VARIABLE error_code
        WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-test
      )
      if(error_code)
        message(FATAL_ERROR "CMake integration test build failed; unable to build executable using target ${_tc_TARGETS} (${BUILD_OUTPUT})")
      endif()
    endif ()
endfunction()