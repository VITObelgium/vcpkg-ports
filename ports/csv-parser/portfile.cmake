include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vincentlaucsb/csv-parser
    REF 1.3.3
    SHA512 1233bceaf065af6468ce3f2a43db8bdf5be21a0dbffd0d00745140d8b04f275eedf210076ca14475b7a9d255601176f2ccdf45bb32884a1413f395946583aa18
    HEAD_REF master
    PATCHES clang-win.patch
)

file(INSTALL ${SOURCE_PATH}/single_include/csv.hpp DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/FindCsvParser.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/cmake)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)