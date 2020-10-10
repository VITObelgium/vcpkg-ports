include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vincentlaucsb/csv-parser
    REF 2.0.1
    SHA512 3cbdb9a8533e1456f39601c9584d381d2e22921e2f91882a1b71aec5848eea3e5ab0ecf05c99ebd8dc7e215b0a0a7a86a0f5d88061e04c7470b7925015445e31
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/single_include/csv.hpp DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/FindCsvParser.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/cmake)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)