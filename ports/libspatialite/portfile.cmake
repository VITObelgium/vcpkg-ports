set(LIBSPATIALITE_VERSION_STR "4.3.0a")
vcpkg_download_distfile(ARCHIVE
    URLS "http://www.gaia-gis.it/gaia-sins/libspatialite-sources/libspatialite-${LIBSPATIALITE_VERSION_STR}.tar.gz"
    FILENAME "libspatialite-${LIBSPATIALITE_VERSION_STR}.tar.gz"
    SHA512 adfd63e8dde0f370b07e4e7bb557647d2bfb5549205b60bdcaaca69ff81298a3d885e7c1ca515ef56dd0aca152ae940df8b5dbcb65bb61ae0a9337499895c3c0
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES
        fix-latin-literals.patch
        fix-sources.patch
        msvc-config.patch # make sure freexl support can be toggled
)

file(
    COPY
        ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt
        ${CMAKE_CURRENT_LIST_DIR}/config.h.cmake.in
        ${CMAKE_CURRENT_LIST_DIR}/libspatialiteConfig.cmake.in
    DESTINATION ${SOURCE_PATH}
)

TEST_FEATURE("freexl" WITH_FREEXL)

set (GEOPKG_SUPPORT ON)
if (VCPKG_TARGET_IS_WINDOWS)
    set (GEOPKG_SUPPORT OFF)
endif ()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DENABLE_GCP=ON
        -DENABLE_GEOPACKAGE=${GEOPKG_SUPPORT}
        -DENABLE_LIBXML2=ON
        -DENABLE_FREEXL=${WITH_FREEXL}
        -DENABLE_LWGEOM=OFF
        -DGEOS_ADVANCED=ON
        -DGEOS_TRUNK=OFF
        -DBUILD_EXAMPLES=OFF
    OPTIONS_DEBUG
        -DINSTALL_DATA_FILES=OFF
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/libspatialite")
vcpkg_copy_pdbs()
vcpkg_test_cmake(PACKAGE_NAME libspatialite)

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/libspatialite RENAME copyright)
