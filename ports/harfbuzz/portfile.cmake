include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO harfbuzz/harfbuzz
    REF 2.6.4
    SHA512 c9b1ad32658d9cd2a8cd0eb25ced9c4beeb40c56c9c8b5388535d9d7b9867eee3a4b455359538b0858267e4d4f1cc3b066297bc0083dfcd4eb8fb97b578ede8c
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
