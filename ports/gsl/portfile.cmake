include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/GSL
    REF v3.0.1
    SHA512 9341d808a5dabbacbbdb4a655ef3b9fdfb4a60e0b31c1fdf7ec6674fa4a9ac2078e546966bac78fea33abe67b40cc60a89cd2d9a45d1880798d60addf2c62ef9
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DGSL_TEST=OFF
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)

file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/FindGsl.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/cmake)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
