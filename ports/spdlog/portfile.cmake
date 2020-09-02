include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gabime/spdlog
    REF v1.8.0
    SHA512 18e9718a0dd58d33b1aef120e9e16123172db07be3758e906b82dee9fbfd0197108a5aa502aabe31dde189a90ff1ee1c14017e8b14fca0aee69e9df84cbf8283
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
