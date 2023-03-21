vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Unidata/netcdf-fortran
    REF v4.6.0
    SHA512 2488c0d9d9df49c56253dda1a411c50bb32a52651bd5d43e303190ca7de06db3f48621da0c7faf48aaee01f7d74031b199fcfbecb2ba523a994c00470680f014
    HEAD_REF master
)

set(CONDITIONAL_LIBS "")
if (EXISTS ${CURRENT_INSTALLED_DIR}/share/hdf5)
    list(APPEND CONDITIONAL_LIBS -lhdf5_hl -lhdf5)
else ()
    message(FATAL_ERROR "${CURRENT_INSTALLED_DIR}/share/hdf5 does not exist")
endif ()

if (EXISTS ${CURRENT_INSTALLED_DIR}/share/openmpi)
    list(APPEND CONDITIONAL_LIBS -lmpi)
endif ()
configure_file(${CMAKE_CURRENT_LIST_DIR}/cacheinit.cmake.in ${SOURCE_PATH}/cacheinit.cmake)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -C${SOURCE_PATH}/cacheinit.cmake
        -DCMAKE_REQUIRED_INCLUDES=${CURRENT_INSTALLED_DIR}/include
        -DCMAKE_REQUIRED_LINK_OPTIONS=-L${CURRENT_INSTALLED_DIR}/lib
        -DBUILD_SHARED_LIBS=OFF
        -DENABLE_TESTS=OFF
        -DBUILD_EXAMPLES=OFF
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/netCDF TARGET_PATH share/netcdf-fortran)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin ${CURRENT_PACKAGES_DIR}/bin)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/CMakeFiles)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYRIGHT DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
#file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/FindnetCDFFortran.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/cmake)
