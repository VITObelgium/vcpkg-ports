set(MAJOR 9)
set(MINOR 0)
set(REVISION 0)
set(VERSION ${MAJOR}.${MINOR}.${REVISION})
set(PACKAGE proj-${VERSION}.tar.gz)

vcpkg_download_distfile(ARCHIVE
    URLS "http://download.osgeo.org/proj/${PACKAGE}"
    FILENAME "${PACKAGE}"
    SHA512 ae1e65f03fba1e922a61f843b64cf4fde0ff015ef8c18bde0a10cb3e732c4d1b27d2c6b0179e8456338c552a760de22abf16e887fc92118288ffa394a9c6a000
)

vcpkg_extract_source_archive_ex(
    ARCHIVE ${ARCHIVE}
    OUT_SOURCE_PATH SOURCE_PATH
)

if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_replace_string(${SOURCE_PATH}/src/lib_proj.cmake "if(WIN32)" "if(MSVC)")
endif ()

if (VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Emscripten")
    set (THREAD_SUPPORT OFF)
else ()
    set (THREAD_SUPPORT ON)
endif ()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS ${CMAKE_OPTIONS}
        -DNLOHMANN_JSON_ORIGIN="internal"
        -DBUILD_TESTING=OFF
        -DBUILD_APPS=OFF # from version 8.2.0
        -DENABLE_CURL=OFF # required for the projsync utility
        -DENABLE_TIFF=OFF
        -DBUILD_PROJSYNC=OFF
        -DUSE_THREAD=${THREAD_SUPPORT}
    OPTIONS_DEBUG
        -DCMAKECONFIGDIR=${CURRENT_PACKAGES_DIR}/debug/share
    OPTIONS_RELEASE
        -DCMAKECONFIGDIR=${CURRENT_PACKAGES_DIR}/share
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets()
vcpkg_test_cmake(PACKAGE_NAME PROJ)

# Remove duplicate headers installed from debug build
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
# Remove data installed from debug build
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/vend)

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)