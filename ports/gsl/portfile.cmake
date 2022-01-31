
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/GSL
    REF v4.0.0
    SHA512 7fa7446796c6bf82fb3bff09f86a69c446a27be528bef3b17c8bc5ad2f24d5cf86bdb3d3813ecb44726e8f395020180e97e41027330d1fbf545cc0f0b44aac29
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DGSL_TEST=OFF
        -DGSL_INSTALL=ON
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(
    CONFIG_PATH share/cmake/Microsoft.GSL
    TARGET_PATH share/Microsoft.GSL
)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)

file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/FindGsl.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/cmake)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
