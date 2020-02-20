if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "${PORT} does not currently support UWP")
endif()

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    message(STATUS "Warning: Dynamic building not supported yet. Building static.")
    set(VCPKG_LIBRARY_LINKAGE static)
endif()

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/benchmark
    REF v1.5.0
    SHA512 a0df9aa3d03f676e302c76d83b436de36eea0a8517ab50a8f5a11c74ccc68a1f5128fa02474901002d8e6b5a4d290ef0272a798ff4670eab3e2d78dc86bb6cd3
    HEAD_REF master
)

# case fixes for mingw builds
vcpkg_replace_string(${SOURCE_PATH}/src/colorprint.cc "<Windows.h>" "<windows.h>")
vcpkg_replace_string(${SOURCE_PATH}/src/sleep.cc "<Windows.h>" "<windows.h>")
vcpkg_replace_string(${SOURCE_PATH}/src/sleep.cc "<Shlwapi.h>" "<shlwapi.h>")
vcpkg_replace_string(${SOURCE_PATH}/src/sysinfo.cc "<Windows.h>" "<windows.h>")
vcpkg_replace_string(${SOURCE_PATH}/src/sysinfo.cc "<Shlwapi.h>" "<shlwapi.h>")
vcpkg_replace_string(${SOURCE_PATH}/src/sysinfo.cc "<VersionHelpers.h>" "<versionhelpers.h>")
vcpkg_replace_string(${SOURCE_PATH}/src/timers.cc "<Windows.h>" "<windows.h>")
vcpkg_replace_string(${SOURCE_PATH}/src/timers.cc "<Shlwapi.h>" "<shlwapi.h>")
vcpkg_replace_string(${SOURCE_PATH}/src/timers.cc "<VersionHelpers.h>" "<versionhelpers.h>")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBENCHMARK_ENABLE_TESTING=OFF
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/benchmark)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/benchmark)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/benchmark/LICENSE ${CURRENT_PACKAGES_DIR}/share/benchmark/copyright)

vcpkg_test_cmake(PACKAGE_NAME benchmark)