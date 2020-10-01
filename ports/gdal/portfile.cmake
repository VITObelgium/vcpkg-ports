include(vcpkg_common_functions)
set(MAJOR 2)
set(MINOR 4)
set(REVISION 4)
set(VERSION ${MAJOR}.${MINOR}.${REVISION})
set(PACKAGE_NAME ${PORT}-${VERSION})
set(PACKAGE ${PACKAGE_NAME}.tar.xz)

vcpkg_download_distfile(ARCHIVE
    URLS "http://download.osgeo.org/${PORT}/${VERSION}/${PACKAGE}"
    FILENAME "${PACKAGE}"
    SHA512 51e8b0fc78a5cd37a89f5fd2b07901313851d866ffb3dd428cb6a4bf9d750ac66cb1b99c6a8874353f14e5a002d295d6328576ec82ce617e757c519774e75616
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES
        copylayer-crash-1.patch # fixed upstream in next release
        copylayer-crash-2.patch # fixed upstream in next release
        netcdf-non-ascii.patch # fixed upstream in 3.x releases
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
TEST_FEATURE("sqlite" WITH_SQLITE)
TEST_FEATURE("spatialite" WITH_SPATIALITE)
TEST_FEATURE("expat" WITH_EXPAT)
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
        -DGDAL_FRMTS_HDF5=${WITH_NETCDF}
        -DGDAL_FRMTS_MBTILES=${WITH_SQLITE}
        -DGDAL_FRMTS_NETCDF=${WITH_NETCDF}
        -DGDAL_FRMTS_PCRASTER=ON
        -DGDAL_FRMTS_RAW=OFF
        -DGDAL_OGR_FRMTS_GEOPKG=${WITH_SPATIALITE}
        -DGDAL_OGR_FRMTS_MVT=${WITH_SQLITE}
        -DGDAL_OGR_FRMTS_SHAPE=ON
        -DGDAL_OGR_FRMTS_SQLITE=${WITH_SQLITE}
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
