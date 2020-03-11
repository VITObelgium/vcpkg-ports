set(VERSION_MAJOR 3)
set(VERSION_MINOR 8)
set(VERSION_REVISION 1)
set(VERSION ${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_REVISION})
set(PACKAGE_NAME ${PORT}-${VERSION})
set(PACKAGE ${PACKAGE_NAME}.tar.bz2)

include(vcpkg_common_functions)

vcpkg_download_distfile(ARCHIVE
    URLS "http://download.osgeo.org/geos/${PACKAGE}"
    FILENAME "${PACKAGE}"
    SHA512 1d8d8b3ece70eb388ea128f4135c7455899f01828223b23890ad3a2401e27104efce03987676794273a9b9d4907c0add2be381ff14b8420aaa9a858cc5941056
)
vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES
        fix-build-without-tests.patch # fixed in the next release
        fix-exported-includes.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" GEOS_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "shared" GEOS_SHARED)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_TESTING=OFF
        -DBUILD_DOCUMENTATION=OFF
)
vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/GEOS")
vcpkg_test_cmake(PACKAGE_NAME GEOS)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# move the geos-config script to the the tools directory
vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/bin/geos-config "packages/${PORT}_${TARGET_TRIPLET}" "installed/${TARGET_TRIPLET}")
file(COPY ${CURRENT_PACKAGES_DIR}/bin/geos-config DESTINATION ${CURRENT_PACKAGES_DIR}/tools)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)