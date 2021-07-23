vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gabime/spdlog
    REF v1.9.0
    SHA512 df023847e49b2ad8e5dc4cb681d31515bb7f87644a4baa946836cf3cb4114bb95ad603b746969e0e7f8220d3bfa453220c00dfde812f1e610801a5cc62e1f0f2
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
