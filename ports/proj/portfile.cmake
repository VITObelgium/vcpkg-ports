set(MAJOR 8)
set(MINOR 2)
set(REVISION 0)
set(VERSION ${MAJOR}.${MINOR}.${REVISION})
set(PACKAGE proj-${VERSION}.tar.gz)

vcpkg_download_distfile(ARCHIVE
    URLS "http://download.osgeo.org/proj/${PACKAGE}"
    FILENAME "${PACKAGE}"
    SHA512 e7bcd959deeeb9130325a7bf63a8a0b8de2c55ba573065ca5ea32cf83c2c2643648760cfbe1c3bd1d2a2e74f65ceae4d9d525a537678386260fc2862b3927f5e
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
        -DBUILD_APPS=OFF
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