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
    cmake_parse_arguments(_tc "MODULE" "PACKAGE_NAME;REQUIRED_HEADER;REQUIRED_FUNCTION" "TARGETS" ${ARGN})

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
      file(APPEND ${VCPKG_TEST_MAIN} "int main(int, char**) { ${_tc_REQUIRED_FUNCTION}; return 0; }\n")
    endif ()

    vcpkg_find_acquire_program(NINJA)
    set(GENERATOR "Ninja")
    set(GENERATOR_OPTIONS -DCMAKE_MAKE_PROGRAM=${NINJA})

    # Run cmake config with a generated CMakeLists.txt
    set(LOGPREFIX "${CURRENT_BUILDTREES_DIR}/test-cmake-${TARGET_TRIPLET}")
    set(PREFIXES ${CURRENT_PACKAGES_DIR} ${CURRENT_PACKAGES_DIR}/debug)

    if(NOT DEFINED VCPKG_CMAKE_SYSTEM_NAME OR _TARGETTING_UWP)
        set(CHAINLOAD_FILE "${VCPKG_ROOT_DIR}/scripts/toolchains/windows.cmake")
    elseif(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Linux")
        set(CHAINLOAD_FILE "${VCPKG_ROOT_DIR}/scripts/toolchains/linux.cmake")
    elseif(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Android")
        set(CHAINLOAD_FILE "${VCPKG_ROOT_DIR}/scripts/toolchains/android.cmake")
    elseif(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Darwin")
        set(CHAINLOAD_FILE "${VCPKG_ROOT_DIR}/scripts/toolchains/osx.cmake")
    elseif(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "iOS")
        set(CHAINLOAD_FILE "${VCPKG_ROOT_DIR}/scripts/toolchains/ios.cmake")
    elseif(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "FreeBSD")
        set(CHAINLOAD_FILE "${VCPKG_ROOT_DIR}/scripts/toolchains/freebsd.cmake")
    elseif(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "MinGW")
        set(CHAINLOAD_FILE "${VCPKG_ROOT_DIR}/scripts/toolchains/mingw.cmake")
    endif()

    execute_process(
      COMMAND ${CMAKE_COMMAND} -G ${GENERATOR} ${GENERATOR_OPTIONS}
          "-DCMAKE_TOOLCHAIN_FILE=${VCPKG_ROOT_DIR}/scripts/buildsystems/vcpkg.cmake"
          "-DCMAKE_FIND_PACKAGE_NO_PACKAGE_REGISTRY=ON"
          "-DCMAKE_FIND_PACKAGE_NO_SYSTEM_PACKAGE_REGISTRY=ON"
          "-DVCPKG_CHAINLOAD_TOOLCHAIN_FILE=${CHAINLOAD_FILE}"
          "-DVCPKG_SET_CHARSET_FLAG=${VCPKG_SET_CHARSET_FLAG}"
          "-DVCPKG_PLATFORM_TOOLSET=${VCPKG_PLATFORM_TOOLSET}"
          "-DVCPKG_TARGET_TRIPLET=${TARGET_TRIPLET}"
          "-DVCPKG_CXX_FLAGS=${VCPKG_CXX_FLAGS}"
          "-DVCPKG_CXX_FLAGS_RELEASE=${VCPKG_CXX_FLAGS_RELEASE}"
          "-DVCPKG_CXX_FLAGS_DEBUG=${VCPKG_CXX_FLAGS_DEBUG}"
          "-DVCPKG_C_FLAGS=${VCPKG_C_FLAGS}"
          "-DVCPKG_C_FLAGS_RELEASE=${VCPKG_C_FLAGS_RELEASE}"
          "-DVCPKG_C_FLAGS_DEBUG=${VCPKG_C_FLAGS_DEBUG}"
          "-DVCPKG_CRT_LINKAGE=${VCPKG_CRT_LINKAGE}"
          "-DVCPKG_LINKER_FLAGS=${VCPKG_LINKER_FLAGS}"
          "-DVCPKG_LINKER_FLAGS_RELEASE=${VCPKG_LINKER_FLAGS_RELEASE}"
          "-DVCPKG_LINKER_FLAGS_DEBUG=${VCPKG_LINKER_FLAGS_DEBUG}"
          "-DVCPKG_TARGET_ARCHITECTURE=${VCPKG_TARGET_ARCHITECTURE}"
          "-DVCPKG_APPLOCAL_DEPS=OFF"
          "-DCMAKE_FIND_ROOT_PATH=${CURRENT_PACKAGES_DIR}"
          "-DCMAKE_MODULE_PATH=${CURRENT_PACKAGES_DIR}/share/cmake;${CURRENT_INSTALLED_DIR}/share/cmake"
          "-B${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-test"
          "-S${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-test"
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