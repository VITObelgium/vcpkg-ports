include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gabime/spdlog
    REF v1.8.1
    SHA512 ef855f4f91ed8aba89ef0191a9fd70f73a49567332f7eb42da1604e3a7dda3bbe48db3fd0fae317bb11ee95315d8cd62bf586d2de919ca0978d91e5a971b1c3f
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
