set(VERSION_MAJOR 0)
set(VERSION_MINOR 58)
set(VERSION ${VERSION_MAJOR}.${VERSION_MINOR})

include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rbock/sqlpp11
    REF ${VERSION}
    SHA512 c391e72638a748e0e25b53176dc371ba468bc14bdcb6dda2f2418c4ab4d620ebc5507ee284ff81c3104888d0d959703c6c91b55ccd69a8641b07dcb20cd56209
    HEAD_REF master
    PATCHES
        float-precision.patch
        msvc-2019.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DENABLE_TESTS=OFF
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

file(COPY ${CMAKE_CURRENT_LIST_DIR}/FindSqlpp11.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/cmake)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
