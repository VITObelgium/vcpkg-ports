include(vcpkg_common_functions)

set(VERSION 3.28.0)
set(SQLITE_VERSION 3280000)
set(SQLITE_HASH 6a2b9c0accd286b09d7e077393a627e22112ef11c76ff6a5896f5ff1a11eb62a8b2700f5a99eebda82df63b3968814ca460582aa4619852f96a899d2f59b9f8d)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/sqlite-amalgamation-${SQLITE_VERSION})

vcpkg_download_distfile(ARCHIVE
    URLS "https://sqlite.org/2019/sqlite-amalgamation-${SQLITE_VERSION}.zip"
    FILENAME "sqlite-amalgamation-${SQLITE_VERSION}.zip"
    SHA512 ${SQLITE_HASH})
vcpkg_extract_source_archive(${ARCHIVE})

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

set(SQLITE3_SKIP_TOOLS ON)
if("tool" IN_LIST FEATURES)
    set(SQLITE3_SKIP_TOOLS OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DSQLITE3_SKIP_TOOLS=${SQLITE3_SKIP_TOOLS}
    OPTIONS_DEBUG
        -DSQLITE3_SKIP_TOOLS=ON
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

configure_file(
    ${CMAKE_CURRENT_LIST_DIR}/sqlite3-config.in.cmake
    ${CURRENT_PACKAGES_DIR}/share/sqlite3/sqlite3-config.cmake
    @ONLY
)

configure_file(
    ${CMAKE_CURRENT_LIST_DIR}/sqlite3.pc.in
    ${CURRENT_PACKAGES_DIR}/lib/pkgconfig/sqlite3.pc
    @ONLY
)

file(WRITE ${CURRENT_PACKAGES_DIR}/share/sqlite3/copyright "SQLite is in the Public Domain.\nhttp://www.sqlite.org/copyright.html\n")
vcpkg_copy_pdbs()

vcpkg_test_cmake(PACKAGE_NAME sqlite3)