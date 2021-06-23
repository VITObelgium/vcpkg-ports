
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO harfbuzz/harfbuzz
    REF 2.8.1
    SHA512 16e43b9182d3ebd2394c2c0e0df815ca9e715d55dc7e46de4eafcde49ddf59cccae69a5340e05c8aa2ee6bc2ba46d1cffae8252d1b2a004ffe9d70c62628cf73
    HEAD_REF master
    PATCHES find-package-freetype-2.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DHB_BUILD_TESTS=OFF
        -DHB_HAVE_FREETYPE=ON
        -DHB_HAVE_ICU=ON
        -DHB_BUILD_UTILS=OFF
        -DHB_HAVE_GOBJECT=OFF
        -DHB_HAVE_CORETEXT=OFF
    OPTIONS_DEBUG
        -DSKIP_INSTALL_HEADERS=ON
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/harfbuzz)
vcpkg_copy_pdbs()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/harfbuzz RENAME copyright)
