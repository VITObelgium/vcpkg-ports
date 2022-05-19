vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stiffstream/restinio
    REF 20140bcecaec6f44ad5a8f68efcd8b44e1375604 # v.0.6.14
    SHA512 e4654342831cb5c9086b60b22a7a15dd68a6769e28936576a1ff61352ea204f8e171bd446d002cefb514fd0cc4842878f23d5d51bc0da48c6224b96e4a0f3b14
    PATCHES
        fmt.patch
        recursivedeps.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/vcpkg"
    OPTIONS
        -DRESTINIO_FMT_HEADER_ONLY=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/restinio)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib" "${CURRENT_PACKAGES_DIR}/debug")
# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
