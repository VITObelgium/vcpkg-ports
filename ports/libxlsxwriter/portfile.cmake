
set(MAJOR 1)
set(MINOR 1)
set(REVISION 4)
set(VERSION ${MAJOR}.${MINOR}.${REVISION})
set(SHA_SUM fad36f7882fcb21b87e13cf603022cfad3f14e6f955a06e2771712facd0fe12f83f4d1655dc1a744724bda1ac83af7e7bf1393457c5507d8983f63002ab294b5)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jmcnamara/libxlsxwriter
    REF RELEASE_${VERSION}
    SHA512 ${SHA_SUM}
    HEAD_REF master
    PATCHES cxxflags.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_TESTS=OFF
        -DBUILD_EXAMPLES=OFF
        -DUSE_NO_MD5=ON
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/FindXlsxWriter.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/cmake)
file(INSTALL ${SOURCE_PATH}/License.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)