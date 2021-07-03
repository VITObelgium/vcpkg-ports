set(MAJOR 8)
set(MINOR 1)
set(REVISION 0)
set(VERSION ${MAJOR}.${MINOR}.${REVISION})
set(PACKAGE proj-${VERSION}.tar.gz)

vcpkg_download_distfile(ARCHIVE
    URLS "http://download.osgeo.org/proj/${PACKAGE}"
    FILENAME "${PACKAGE}"
    SHA512 0c11d43bcdf97fbb3be9238c77cc111ae6df7948dc5076b1a31350c84a60299964ea1a320edfbee0568a2d9d3c7f80eafa6322adfdf99aea5f06172d7ee53a2f
)

vcpkg_extract_source_archive_ex(
    ARCHIVE ${ARCHIVE}
    OUT_SOURCE_PATH SOURCE_PATH
)

if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_replace_string(${SOURCE_PATH}/src/lib_proj.cmake "if(WIN32)" "if(MSVC)")
endif ()

vcpkg_replace_string(${SOURCE_PATH}/CMakeLists.txt "add_subdirectory(test)" "#add_subdirectory(test)")

if (VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Emscripten")
    set (THREAD_SUPPORT OFF)
else ()
    set (THREAD_SUPPORT ON)
endif ()

vcpkg_replace_string(${SOURCE_PATH}/src/lib_proj.cmake
    "-DPROJ_LIB=\"\${CMAKE_INSTALL_PREFIX}/\${DATADIR}\""
    "-DPROJ_LIB=\"\${VCPKG_INSTALL_PREFIX}/\${DATADIR}\""
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS ${CMAKE_OPTIONS}
        -DNLOHMANN_JSON_ORIGIN="internal"
        -DBUILD_TESTING=OFF
        -DBUILD_NAD2BIN=OFF
        -DBUILD_PROJ=OFF
        -DBUILD_GEOD=OFF
        -DBUILD_CS2CS=OFF
        -DBUILD_CCT=OFF
        -DBUILD_GIE=OFF
        -DBUILD_PROJINFO=OFF
        -DENABLE_CURL=OFF # required for the projsync utility
        -DENABLE_TIFF=OFF
        -DBUILD_PROJSYNC=OFF
        -DUSE_THREAD=${THREAD_SUPPORT}
        -DVCPKG_INSTALL_PREFIX=${CURRENT_INSTALLED_DIR}
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

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)