vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO oneapi-src/oneTBB
    REF v2021.3.0
    SHA512 969bc8d1dcf50bd12f70633d0319e46308eb1667cdc6f0503b373a35dcb2fe6b2adf59c26bd3c8e2a99a8d2d8b9f64088db5a43e784218b163b3661d12908c0e
    HEAD_REF master
    PATCHES threads-target.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DTBB_TEST=OFF
        -DTBB_EXAMPLES=OFF
        -DTBB_STRICT=OFF
        -DTBB4PY_BUILD=OFF
        -DTBB_CPF=OFF
        -DTBB_DISABLE_HWLOC_AUTOMATIC_SEARCH=ON
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/TBB)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})

vcpkg_test_cmake(PACKAGE_NAME TBB)
