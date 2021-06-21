vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO VcDevel/Vc
    REF 1.4.1
    SHA512 dd17e214099796c41d70416d365ea038c00c5fda285b05e48d7ee4fe03f4db2671d2be006ca7b98b0d4133bfcb57faf04cecfe35c29c3b006cd91c9a185cc04a
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

file(INSTALL ${SOURCE_PATH}/cmake/msvc_version.c DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)


file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

vcpkg_test_cmake(PACKAGE_NAME Vc)