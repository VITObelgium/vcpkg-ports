set(VERSION_MAJOR 0)
set(VERSION_MINOR 61)
set(VERSION ${VERSION_MAJOR}.${VERSION_MINOR})

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rbock/sqlpp11
    REF ${VERSION}
    SHA512 f180f863a25f671d3909f807748568bde8d66c3c236bd5777780240b5cffe6c6545e9627762caf4a488b28939f459813a3298e7d6aa52e9443639639a55f67ab
    HEAD_REF master
    PATCHES
        #float-precision.patch
        #msvc-2019.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        sqlite      BUILD_SQLITE3_CONNECTOR
        postgresql  BUILD_POSTGRESQL_CONNECTOR
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        ${FEATURE_OPTIONS}
        -DBUILD_TESTING=OFF
        -DUSE_SYSTEM_DATE=ON
)


vcpkg_install_cmake()
if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/bin)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/sqlpp11.dll ${CURRENT_PACKAGES_DIR}/bin/sqlpp11.dll)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/sqlpp11d.dll ${CURRENT_PACKAGES_DIR}/debug/bin/sqlpp11d.dll)
endif()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/Sqlpp11)

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools)
file(RENAME ${CURRENT_PACKAGES_DIR}/bin/sqlpp11-ddl2cpp ${CURRENT_PACKAGES_DIR}/tools/sqlpp11-ddl2cpp)
vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/share/${PORT}/Sqlpp11Config.cmake "../bin/sqlpp11-ddl2cpp" "tools/sqlpp11-ddl2cpp")
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)

vcpkg_copy_pdbs()

#file(COPY ${CMAKE_CURRENT_LIST_DIR}/FindSqlpp11.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/cmake)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

vcpkg_test_cmake(PACKAGE_NAME Sqlpp11 REQUIRED_HEADER sqlpp11/sqlpp11.h TARGETS sqlpp11::sqlpp11)
