set(VERSION_MAJOR 1)
set(VERSION_MINOR 12)
set(VERSION_REVISION 0)
set(VERSION ${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_REVISION})
set(PACKAGE_NAME ${PORT}-${VERSION})
set(PACKAGE CMake-${PACKAGE_NAME}.tar.gz)

vcpkg_download_distfile(ARCHIVE
    URLS "https://support.hdfgroup.org/ftp/HDF5/releases/${PORT}-${VERSION_MAJOR}.${VERSION_MINOR}/${PACKAGE_NAME}/src/${PACKAGE}"
    FILENAME "${PACKAGE}"
    SHA512 67b415d2125010d587003c76ffdbd8b9b27ea79bf3309c1a916f57f9fe008b83b08067325961307d16adc03b7d8b90fbfcd6cd30eb2b49619112614afc8ae6ef
)
vcpkg_extract_source_archive_ex(
    ARCHIVE ${ARCHIVE}
    OUT_SOURCE_PATH SOURCE_PATH
    PATCHES
        transitive-mpi.patch
        transitive-zlib.patch
        #libsettings-cross.patch
        #mingw.patch
        #mingw-libname.patch # fix liblibhdf.a name for static libraries on mingw
)

if (VCPKG_CMAKE_SYSTEM_NAME STREQUAL Windows AND NOT CMAKE_HOST_SYSTEM STREQUAL Windows)
    # copy the generated file in case of mingw cross compilation
    set (INIT_CACHE_ARG -C ${CMAKE_CURRENT_LIST_DIR}/TryRunResults-mingw.cmake)
    file(COPY ${CMAKE_CURRENT_LIST_DIR}/gen DESTINATION ${CURRENT_BUILDTREES_DIR})
    set(CROSS_COMPILE_OPTIONS
        -DHDF5_USE_PREGEN=ON
        -DHDF5_GENERATED_SOURCE_DIR=${CURRENT_BUILDTREES_DIR}/gen
    )
endif ()

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" DISABLE_STATIC_LIBS)

TEST_FEATURE("parallel" ENABLE_PARALLEL)
TEST_FEATURE("cpp" ENABLE_CPP)
TEST_FEATURE("fortran" ENABLE_FORTRAN)
TEST_FEATURE("tools" ENABLE_TOOLS)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/${PACKAGE_NAME}
    DISABLE_PARALLEL_CONFIGURE
    PREFER_NINJA
    OPTIONS
        "${INIT_CACHE_ARG}"
        -DMPIEXEC_EXECUTABLE=${CURRENT_INSTALLED_DIR}/tools/mpiexec
        -DMPI_HOME=${CURRENT_INSTALLED_DIR}
        -DBUILD_TESTING=OFF
        -DDISABLE_STATIC_LIBS=${DISABLE_STATIC_LIBS}
        -DHDF5_BUILD_HL_LIB=ON
        -DHDF5_BUILD_EXAMPLES=OFF
        -DHDF5_BUILD_FORTRAN=${ENABLE_FORTRAN}
        -DSKIP_HDF5_FORTRAN_SHARED=ON
        -DHDF5_BUILD_CPP_LIB=${ENABLE_CPP}
        -DHDF5_ENABLE_PARALLEL=${ENABLE_PARALLEL}
        -DHDF5_ENABLE_Z_LIB_SUPPORT=ON
        -DHDF5_ENABLE_SZIP_SUPPORT=OFF
        -DHDF5_ENABLE_SZIP_ENCODING=OFF
        -DHDF5_INSTALL_DATA_DIR=share/hdf5/data
        -DHDF5_INSTALL_CMAKE_DIR=share
        -DHDF5_NO_PACKAGES=ON
        ${CROSS_COMPILE_OPTIONS}
    OPTIONS_RELEASE
        -DHDF5_BUILD_TOOLS=${ENABLE_TOOLS}
    OPTIONS_DEBUG
        -DHDF5_BUILD_TOOLS=OFF
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(RENAME ${CURRENT_PACKAGES_DIR}/share/hdf5/data/COPYING ${CURRENT_PACKAGES_DIR}/share/hdf5/copyright)

vcpkg_fixup_cmake_targets(CONFIG_PATH share/hdf5)
vcpkg_fixup_pkgconfig_mod(NAMES hdf5-${VERSION} hdf5_hl-${VERSION})
if(ENABLE_CPP)
    vcpkg_fixup_pkgconfig_mod(NAMES hdf5_cpp-${VERSION} hdf5_hl_cpp-${VERSION})
endif()

file(GLOB TOOL_FILES ${CURRENT_PACKAGES_DIR}/bin/*)
file(COPY ${TOOL_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/tools)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig)

vcpkg_test_cmake(PACKAGE_NAME hdf5)
