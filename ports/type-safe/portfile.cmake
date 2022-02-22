vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO foonathan/type_safe
    REF b09a8d3588364efa48d7913974ebacb7d67dd73f
    SHA512 84c45fb088eb384626431527d4201a52bcff0de18f19c8382377bfd5a99e6d1ea219244caec2e73b85fbdca4d2cf684d2949ed4219472ef11347ee210c4949ee
    HEAD_REF v0.2.2
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DTYPE_SAFE_BUILD_TEST_EXAMPLE=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/type_safe TARGET_PATH share/type_safe)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug ${CURRENT_PACKAGES_DIR}/lib)

vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
