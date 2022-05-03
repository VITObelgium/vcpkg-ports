set(VERSION_MAJOR 3)
set(VERSION_MINOR 10)
set(VERSION_REVISION 2)
set(VERSION ${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_REVISION})
set(PACKAGE_NAME ${PORT}-${VERSION})
set(PACKAGE ${PACKAGE_NAME}.tar.bz2)


vcpkg_download_distfile(ARCHIVE
    URLS "http://download.osgeo.org/geos/${PACKAGE}"
    FILENAME "${PACKAGE}"
    SHA512 390381711ccf56b862c2736cf6329200822f121de1c49df52b8b85cabea8c7787b199df2196acacc2e5c677ff3ebe042d93d70e89deadbc19d754499edb65126
)
vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES
        charset.patch
        fix-exported-includes.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_TESTING=OFF
        -DBUILD_DOCUMENTATION=OFF
        -DBUILD_GEOSOP=OFF
)
vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/GEOS")
vcpkg_test_cmake(PACKAGE_NAME GEOS)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
if (EXISTS ${CURRENT_PACKAGES_DIR}/bin/geos-config)
    vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/bin/geos-config "packages/${PORT}_${TARGET_TRIPLET}" "installed/${TARGET_TRIPLET}")
    file(COPY ${CURRENT_PACKAGES_DIR}/bin/geos-config DESTINATION ${CURRENT_PACKAGES_DIR}/tools)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif ()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)