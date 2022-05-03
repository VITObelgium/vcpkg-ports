set(MAJOR 3)
set(MINOR 4)
set(REVISION 2)
set(VERSION ${MAJOR}.${MINOR}.${REVISION})
set(PACKAGE_NAME ${PORT}-${VERSION})
set(PACKAGE ${PACKAGE_NAME}.tar.xz)

vcpkg_download_distfile(ARCHIVE
    URLS "http://download.osgeo.org/${PORT}/${VERSION}/${PACKAGE}"
    FILENAME "${PACKAGE}"
    SHA512 7b7e2800b2c23ffe6b7739fbf77748e3be2db9e34b061753da5e175f6ad6ed7f9f91856d3838f071a17a6afab96c258d37a15502e254d2008310d3061031af73
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES xlsx-error.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt
          ${CMAKE_CURRENT_LIST_DIR}/cpl_config.h.cmake.in
          ${CMAKE_CURRENT_LIST_DIR}/cpl_config.h.vc.cmake.in
          ${CMAKE_CURRENT_LIST_DIR}/GDALConfig.cmake.in
     DESTINATION ${SOURCE_PATH}
)

TEST_FEATURE("png" WITH_PNG)
TEST_FEATURE("geos" WITH_GEOS)
TEST_FEATURE("jpeg" WITH_JPEG)
TEST_FEATURE("gif" WITH_GIF)
TEST_FEATURE("grib" WITH_GRIB)
TEST_FEATURE("sqlite" WITH_SQLITE)
TEST_FEATURE("spatialite" WITH_SPATIALITE)
TEST_FEATURE("expat" WITH_EXPAT)
TEST_FEATURE("freexl" WITH_FREEXL)
TEST_FEATURE("pcraster" WITH_PCRASTER)
TEST_FEATURE("netcdf" WITH_NETCDF)
TEST_FEATURE("opencl" WITH_OPENCL)
TEST_FEATURE("network" WITH_CURL)
TEST_FEATURE("tools" WITH_TOOLS)

if (WITH_SPATIALITE)
    set (WITH_SQLITE ON)
endif ()

set (WITH_ICONV ON)
if (MINGW)
set (WITH_ICONV OFF)
endif ()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DGDAL_THREAD_SUPPORT=ON
        -DGDAL_ZLIB_SUPPORT=ON
        -DGDAL_PNG_SUPPORT=${WITH_PNG}
        -DGDAL_JPEG_SUPPORT=${WITH_JPEG}
        -DGDAL_GEOS_SUPPORT=${WITH_GEOS}
        -DGDAL_ICONV_SUPPORT=${WITH_ICONV}
        -DGDAL_CURL_SUPPORT=${WITH_CURL}
        -DGDAL_FRMTS_AAIGRID=ON
        -DGDAL_FRMTS_BMP=OFF
        -DGDAL_FRMTS_GIF=${WITH_GIF}
        -DGDAL_FRMTS_GRIB=${WITH_GRIB}
        -DGDAL_FRMTS_HDF5=${WITH_NETCDF}
        -DGDAL_FRMTS_MBTILES=${WITH_SQLITE}
        -DGDAL_FRMTS_NETCDF=${WITH_NETCDF}
        -DGDAL_FRMTS_PCRASTER=ON
        -DGDAL_FRMTS_RAW=OFF
        -DGDAL_OGR_FRMTS_GEOPKG=${WITH_SPATIALITE}
        -DGDAL_OGR_FRMTS_MVT=${WITH_SQLITE}
        -DGDAL_OGR_FRMTS_SHAPE=ON
        -DGDAL_OGR_FRMTS_SQLITE=${WITH_SQLITE}
        -DGDAL_OGR_FRMTS_XLS=${WITH_FREEXL}
        -DGDAL_OGR_FRMTS_XLSX=${WITH_EXPAT}
        -DGDAL_OGR_FRMTS_CSV=ON
        -DGDAL_OPENCL_SUPPORT=${WITH_OPENCL}
    OPTIONS_RELEASE
        -DGDAL_BUILD_TOOLS=${WITH_TOOLS}
    OPTIONS_DEBUG
        -DGDAL_INSTALL_DATA_FILES=OFF
        -DGDAL_BUILD_TOOLS=OFF
)

#vcpkg_fixup_pkgconfig_mod()
vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/gdal")
vcpkg_copy_pdbs()
vcpkg_test_cmake(PACKAGE_NAME GDAL)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

if (WITH_TOOLS)
    file(GLOB TOOLS "${CURRENT_PACKAGES_DIR}/bin/*")
    file(COPY ${TOOLS} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT})
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
endif ()

# Handle copyright
file(INSTALL ${CURRENT_PACKAGES_DIR}/share/gdal/LICENSE.TXT DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
