vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO VcDevel/Vc
    REF 1.4.3
    SHA512 7c0c4ccf8c7c4585334482135f2daf1a5bc088114b880093893583bdcea1fbfcec02485da6059304c510c8b1bb1b768ef04fd7ac8ccb21b9ebbad5d0d5babaef
    HEAD_REF master
    PATCHES asm.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_TESTING=OFF
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/Vc")
vcpkg_copy_pdbs()

vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/share/${PORT}/VcConfig.cmake
    "set_and_check(Vc_CMAKE_MODULES_DIR \${Vc_LIB_DIR}/cmake/Vc)"
    "set_and_check(Vc_CMAKE_MODULES_DIR \${Vc_LIB_DIR}/../share/vc)"
)

vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/share/${PORT}/VcConfig.cmake
    "include(\"\${PACKAGE_PREFIX_DIR}/lib/cmake/Vc/VcTargets.cmake\")"
    "include(\"\${PACKAGE_PREFIX_DIR}/share/vc/VcTargets.cmake\")"
)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)


file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

vcpkg_test_cmake(PACKAGE_NAME Vc)