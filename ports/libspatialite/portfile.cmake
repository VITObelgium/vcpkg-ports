set(LIBSPATIALITE_VERSION_STR "5.0.1")
vcpkg_download_distfile(ARCHIVE
    URLS "http://www.gaia-gis.it/gaia-sins/libspatialite-sources/libspatialite-${LIBSPATIALITE_VERSION_STR}.tar.gz"
    FILENAME "libspatialite-${LIBSPATIALITE_VERSION_STR}.tar.gz"
    SHA512 c2552994bc30d69d1e80aa274760f048cd384f71e8350a1e48a47cb8222ba71a1554a69c6534eedde9a09dc582c39c089967bcc1c57bf158cc91a3e7b1840ddf
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES
        fix-latin-literals.patch
        config.patch # make sure freexl support can be toggled
)

file(
    COPY
        ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt
        ${CMAKE_CURRENT_LIST_DIR}/config.h.cmake.in
        ${CMAKE_CURRENT_LIST_DIR}/libspatialiteConfig.cmake.in
    DESTINATION ${SOURCE_PATH}
)

TEST_FEATURE("freexl" WITH_FREEXL)

set(VCPKG_ALLOW_SYSTEM_LIBS OFF)
if (VCPKG_TARGET_IS_OSX)
    set (VCPKG_ALLOW_SYSTEM_LIBS ON)
endif ()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DENABLE_GCP=ON
        -DENABLE_GEOPACKAGE=ON
        -DENABLE_LIBXML2=ON
        -DENABLE_FREEXL=${WITH_FREEXL}
        -DENABLE_RTTOPO=OFF # GPL
        -DGEOS_ADVANCED=ON
        -DGEOS_TRUNK=OFF
        -DBUILD_EXAMPLES=OFF
        -DVCPKG_ALLOW_SYSTEM_LIBS=${VCPKG_ALLOW_SYSTEM_LIBS}
    OPTIONS_DEBUG
        -DINSTALL_DATA_FILES=OFF
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/libspatialite")
vcpkg_copy_pdbs()
vcpkg_test_cmake(PACKAGE_NAME libspatialite)

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/libspatialite RENAME copyright)
