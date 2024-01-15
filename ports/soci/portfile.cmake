vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SOCI/soci
    REF v4.0.3
    SHA512 d501f55e7e7408e46b4823fd8a97d6ef587f5db0f5b98434be8dfc5693c91b8c3b84a24454279c83142ab1cd1fa139c6e54d6d9a67397b2ead61650fcc88bcdb
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" SOCI_DYNAMIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" SOCI_STATIC)

TEST_FEATURE("sqlite3" WITH_SQLITE3)
TEST_FEATURE("postgresql" WITH_POSTGRESQL)

# Handle features
set(_COMPONENT_FLAGS "")
foreach(_feature IN LISTS ALL_FEATURES)
    # Uppercase the feature name and replace "-" with "_"
    string(TOUPPER "${_feature}" _FEATURE)
    string(REPLACE "-" "_" _FEATURE "${_FEATURE}")

    # Turn "-DWITH_*=" ON or OFF depending on whether the feature
    # is in the list.
    if(_feature IN_LIST FEATURES)
        list(APPEND _COMPONENT_FLAGS "-DWITH_${_FEATURE}=ON")
    else()
        list(APPEND _COMPONENT_FLAGS "-DWITH_${_FEATURE}=OFF")
    endif()
endforeach()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DSOCI_TESTS=OFF
        -DSOCI_CXX_C11=ON
        -DSOCI_LIBDIR:STRING=lib # This is to always have output in the lib folder and not lib64 for 64-bit builds
        -DLIBDIR:STRING=lib
        -DSOCI_STATIC=${SOCI_STATIC}
        -DSOCI_SHARED=${SOCI_DYNAMIC}
        ${_COMPONENT_FLAGS}

        -DWITH_MYSQL=OFF
        -DWITH_ORACLE=OFF
        -DWITH_FIREBIRD=OFF
        -DWITH_DB2=OFF
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/cmake ${CURRENT_PACKAGES_DIR}/debug/cmake ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE_1_0.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

configure_file(${CMAKE_CURRENT_LIST_DIR}/FindSoci.cmake.in ${CURRENT_PACKAGES_DIR}/share/cmake/FindSoci.cmake @ONLY)

vcpkg_copy_pdbs()
