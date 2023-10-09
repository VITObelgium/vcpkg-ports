vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO VcDevel/Vc
    REF 1.4.4
    SHA512 b8aa0a45637dd1e0cc23f074d023b677aab570dd4a78cff94e4c2d832afb841c1b421077ae9c848a40aa4beb50ed2e31fdf075738496856ff8fe3ea1d0acba07
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