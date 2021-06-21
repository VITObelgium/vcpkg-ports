
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Unidata/netcdf-cxx4
    REF v4.3.1
    SHA512 404711eb80d5e78968c0f6cbdcb08855a2778d7fd94e7ee94bdc9d1cd72848ac3327613c6437a7634349f26bc463b950092a2999abb34ddab0a47ad185547d22
    HEAD_REF master
    PATCHES
        hdf5check.patch # rely on the transitive hdf5 dependency of netcdf and remove the brittle hdf5 check
)

if (VCPKG_TARGET_IS_WINDOWS)
    set(CACHE_INIT ${CMAKE_CURRENT_LIST_DIR}/cacheinit-msvc.cmake)
    set(LINK_PATH /LIBPATH:${CURRENT_INSTALLED_DIR}/lib)
else ()
    set(CACHE_INIT ${CMAKE_CURRENT_LIST_DIR}/cacheinit.cmake)
    set(LINK_PATH -L${CURRENT_INSTALLED_DIR}/lib)
endif ()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -C${CACHE_INIT}
        -DNCXX_ENABLE_TESTS=OFF
        -DNC_HDF5_LINK_TYPE=static
        -DHAVE_H5FREE_MEMORY=TRUE
        -DCMAKE_REQUIRED_LINK_OPTIONS=${LINK_PATH}
        -DNC_HAS_DEF_VAR_FILTER=OFF # do not build the plugins
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/netCDFCxx)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYRIGHT DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)