set(MAJOR 9)
set(MINOR 2)
set(REVISION 0)
set(VERSION ${MAJOR}.${MINOR}.${REVISION})
set(PACKAGE proj-${VERSION}.tar.gz)

vcpkg_download_distfile(ARCHIVE
    URLS "http://download.osgeo.org/proj/${PACKAGE}"
    FILENAME "${PACKAGE}"
    SHA512 b9c5c72ba2ff1ab4b3c34ab43da411613d27e5206d38c734909fd7a8ab84a113f25a85633c1da1d35af5de22534e3d82f5a66edae52547d3016b51c3bf53f771
)

vcpkg_extract_source_archive_ex(
    ARCHIVE ${ARCHIVE}
    OUT_SOURCE_PATH SOURCE_PATH
    PATCHES inteloneapi.patch
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
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/proj)
vcpkg_test_cmake(PACKAGE_NAME PROJ)

# Remove duplicate headers installed from debug build
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
# Remove data installed from debug build
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/vend)

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)