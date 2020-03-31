include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vincentlaucsb/csv-parser
    REF 1.3.0
    SHA512 b2496bd6a9906ac46f652d252b6f5402291f6bec85cb11c6607c8c8f25244ceb99da503da579d6c8e5299724b7004da315b6f19a1e1bb849545abc01d92e08dd
    HEAD_REF master
    PATCHES clang-win.patch
)

file(INSTALL ${SOURCE_PATH}/single_include/csv.hpp DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/FindCsvParser.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/cmake)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)