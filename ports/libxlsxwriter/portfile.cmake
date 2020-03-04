include(vcpkg_common_functions)

set(MAJOR 0)
set(MINOR 9)
set(REVISION 4)
set(VERSION ${MAJOR}.${MINOR}.${REVISION})
set(SHA_SUM d7bc319e6b9cd2ad6aaa2f3eb6fdce1c5bcc1d5af23ffb3413e29760191f6aed41f836aaa71a322efe7966f3753a6d8a01cb0b403d682b13a6a3734a87cc12ba)

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