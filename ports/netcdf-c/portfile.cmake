include(vcpkg_common_functions)
set(VERSION_MAJOR 4)
set(VERSION_MINOR 7)
set(VERSION_REVISION 4)
set(VERSION ${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_REVISION})

TEST_FEATURE("hdf5" WITH_HDF5)
TEST_FEATURE("tools" WITH_UTILITIES)
TEST_FEATURE("parallel" WITH_PARALLEL)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Unidata/netcdf-c
    REF v${VERSION}
    SHA512 15922818fdd71be285eb7dd2fc9be2594fe9af979de3ed316465636c7bbdaec65eb151ca57ef8b703e6a360cdba036b8f9bc193ddff01ff7ce4214c0a66efa79
    HEAD_REF master
    PATCHES
        libm.patch
        hdf5-targets.patch
        transitive-hdf5.patch
        nc-config.patch
        no-install-deps.patch
        backtrace.patch # only support backtrace when using glibc
        #config-pkg-location.patch
        #mingw.patch
)

file(REMOVE ${SOURCE_PATH}/cmake/modules/FindZLIB.cmake)
file(REMOVE ${SOURCE_PATH}/cmake/modules/windows/FindHDF5.cmake)
foreach (TOOL ncgen ncgen3 ncdump)
    vcpkg_replace_string(${SOURCE_PATH}/${TOOL}/CMakeLists.txt "DESTINATION bin" "DESTINATION tools")
endforeach()

if (VCPKG_CMAKE_SYSTEM_NAME STREQUAL Windows AND NOT CMAKE_HOST_WIN32)
    set (INIT_CACHE_ARG ${CMAKE_CURRENT_LIST_DIR}/TryRunResults-mingw.cmake)
else ()
    # make sure check_library_exist calls work without linker errors
    if (WITH_PARALLEL AND VCPKG_TARGET_IS_LINUX)
        set (INIT_CACHE_ARG ${CMAKE_CURRENT_LIST_DIR}/cacheinitpar.cmake)
    else ()
        set (INIT_CACHE_ARG ${CMAKE_CURRENT_LIST_DIR}/cacheinit.cmake)
    endif ()
endif ()

if (NOT VCPKG_TARGET_IS_WINDOWS)
    set(LIBM_CONFIG -DHAVE_LIBM=-lm)
endif ()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    OPTIONS
        -C${INIT_CACHE_ARG}
        ${LIBM_CONFIG}
        -DBUILD_UTILITIES=${WITH_UTILITIES}
        -DBUILD_TESTING=OFF
        -DENABLE_EXAMPLES=OFF
        -DENABLE_TESTS=OFF
        -DENABLE_DYNAMIC_LOADING=OFF
        -DUSE_HDF5=${WITH_HDF5}
        -DENABLE_NETCDF_4=${WITH_HDF5}
        -DENABLE_DAP=OFF
        -DENABLE_DAP_REMOTE_TESTS=OFF
        -DENABLE_PARALLEL4=${WITH_PARALLEL}
        -DDISABLE_INSTALL_DEPENDENCIES=ON
        -DCMAKE_REQUIRED_LINK_OPTIONS=-L${CURRENT_INSTALLED_DIR}/lib
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/netCDF)

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools)
file(RENAME ${CURRENT_PACKAGES_DIR}/bin/nc-config ${CURRENT_PACKAGES_DIR}/tools/nc-config)
vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/tools/nc-config "${CURRENT_PACKAGES_DIR}" "${CURRENT_INSTALLED_DIR}")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static" AND WITH_HDF5)
    vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/tools/nc-config "-lnetcdf" "-lnetcdf -lhdf5_hl -lhdf5 -lz")
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin ${CURRENT_PACKAGES_DIR}/bin)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

vcpkg_fixup_pkgconfig_file(NAMES netcdf)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYRIGHT DESTINATION ${CURRENT_PACKAGES_DIR}/share/netcdf-c RENAME copyright)

vcpkg_test_cmake(PACKAGE_NAME netCDF)
