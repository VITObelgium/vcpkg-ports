include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gabime/spdlog
    REF v1.8.2
    SHA512 7a0a2353a10187cc314253b366fc46be8f9fe2480d2cbac3a96a8e6825ee4b62b0a5ebb3add2b22b5d7ca8fe6dddd963926603e5296e3431c0a4f7ac42beda7f
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DSPDLOG_BUILD_TESTS=OFF
        -DSPDLOG_BUILD_BENCH=OFF
        -DSPDLOG_BUILD_EXAMPLES=OFF
        -DSPDLOG_FMT_EXTERNAL=ON
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})
vcpkg_test_cmake(PACKAGE_NAME spdlog REQUIRED_HEADER spdlog/spdlog.h TARGETS spdlog::spdlog)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/spdlog)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/spdlog)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/spdlog RENAME copyright)
