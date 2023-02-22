
set(MAJOR 1)
set(MINOR 1)
set(REVISION 5)
set(VERSION ${MAJOR}.${MINOR}.${REVISION})
set(SHA_SUM bd7db0fcf25ebf492b4d8f7da8fdb6cc79400d7d0fa5856ddae259cb24817034fc97d4828cbde42434f41198dcfb6732ac63c756abd962689f4249ca64bf19c6)

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