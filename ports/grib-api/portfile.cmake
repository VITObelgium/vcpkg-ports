
set(VERSION_MAJOR 1)
set(VERSION_MINOR 28)
set(VERSION_REVISION 0)
set(VERSION ${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_REVISION})
set(PACKAGE_NAME grib_api-${VERSION}-Source)
set(PACKAGE ${PACKAGE_NAME}.tar.gz)

TEST_FEATURE("png" PNG_OPT)
TEST_FEATURE("jpeg" JPEG_OPT)
TEST_FEATURE("netcdf" NETCDF_OPT)
TEST_FEATURE("fortran" FORTRAN_OPT)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${CMAKE_CURRENT_LIST_DIR}/${PACKAGE}
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DVCPKG_ALLOW_SYSTEM_LIBS=ON # to find cmath
        -DENABLE_EXAMPLES=OFF
        -DENABLE_NETCDF=${NETCDF_OPT}
        -DENABLE_PYTHON=OFF
        -DENABLE_FORTRAN=${FORTRAN_OPT}
        -DENABLE_PNG=${PNG_OPT}
        -DENABLE_JPG=${JPEG_OPT}
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets(CONFIG_PATH "share/grib_api/cmake")

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin ${CURRENT_PACKAGES_DIR}/bin)
endif()

#vcpkg_fixup_pkgconfig_mod()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
