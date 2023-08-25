vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gabime/spdlog
    REF v1.12.0
    SHA512 db9a4f13b6c39ffde759db99bcdfe5e2dbe4231e73b29eb906a3fa78d6b8ec66920b8bd4371df17ae21b7b562472a236bc4435678f3af92b6496be090074181d
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DSPDLOG_BUILD_TESTS=OFF
        -DSPDLOG_BUILD_BENCH=OFF
        -DSPDLOG_BUILD_EXAMPLE=OFF
        -DSPDLOG_FMT_EXTERNAL=ON
        -DSPDLOG_NO_THREAD_ID=ON
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})
vcpkg_test_cmake(PACKAGE_NAME spdlog REQUIRED_HEADER spdlog/spdlog.h TARGETS spdlog::spdlog)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/spdlog)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/spdlog)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/spdlog RENAME copyright)
