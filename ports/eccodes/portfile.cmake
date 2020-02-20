include(vcpkg_common_functions)

set(VERSION_MAJOR 2)
set(VERSION_MINOR 9)
set(VERSION_REVISION 2)
set(VERSION ${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_REVISION})
set(PACKAGE_NAME ${PORT}-${VERSION}-Source)
set(PACKAGE ${PACKAGE_NAME}.tar.gz)

vcpkg_download_distfile(ARCHIVE
    URLS "https://software.ecmwf.int/wiki/download/attachments/45757960/${PACKAGE}"
    FILENAME "${PACKAGE}"
    SHA512 94d077bb0f348c4d64883a4f0877439c123786c73d2b64e4bdfb3f7eb28e445ff1e0eeb57140261906b8aef8e22fd3d614528f1821877ebe6bcb9d38393921d9
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES
        static-assert.patch
        static-linking.patch
)

TEST_FEATURE("png" PNG_OPT)
TEST_FEATURE("jpeg" JPEG_OPT)
TEST_FEATURE("netcdf" NETCDF_OPT)

if (TARGET_TRIPLET MATCHES "^.*-musl$" OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL Windows AND NOT CMAKE_HOST_WIN32)
    # musl toolchains cannot detect the endiannes, because the linker flags are not set properly for the test program
    # assume little endian
    set(ENDIAN_OPTIONS -DENABLE_OS_ENDINESS_TEST=OFF -DIEEE_LE=1 -DIEEE_BE=0)
endif ()

if (VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Linux")
    # finding the math library fails on some toolchains
    # on apple libm is not presen on disk, so detection fails
    set(VCPKG_LINKER_FLAGS "${VCPKG_LINKER_FLAGS} -lm")
endif ()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DENABLE_EXAMPLES=OFF
        -DENABLE_NETCDF=${NETCDF_OPT}
        -DENABLE_PYTHON=OFF
        -DENABLE_FORTRAN=OFF
        -DENABLE_MEMFS=OFF
        -DENABLE_TESTS=OFF
        -DENABLE_PNG=${PNG_OPT}
        -DENABLE_JPG=${JPEG_OPT}
        -DENABLE_INSTALL_ECCODES_SAMPLES=OFF
        -DBUILD_SHARED_LIBS=OFF
        -DDISABLE_OS_CHECK=ON
        ${ENDIAN_OPTIONS}
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets(CONFIG_PATH "share/${PORT}/cmake")

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)

if("tool" IN_LIST FEATURES)
    file(RENAME ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/tools)
else ()
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
endif()

vcpkg_fixup_pkgconfig_file()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
