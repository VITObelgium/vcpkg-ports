set(VERSION_MAJOR 0)
set(VERSION_MINOR 30)
set(VERSION ${VERSION_MAJOR}.${VERSION_MINOR})

include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rbock/${PORT}
    REF ${VERSION}
    SHA512 298470a39534a725c48d8c5467d0993b43742348842649aec6c873f2615cdcb602ab61c37df9de70005abb603ecd451b433babccf660b2d67c2294e4dbd8d65c
    HEAD_REF master
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/float-precision.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DENABLE_TESTS=OFF
        -DSQLPP11_INCLUDE_DIR:FILEPATH=${CURRENT_INSTALLED_DIR}/include
)

vcpkg_install_cmake()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
