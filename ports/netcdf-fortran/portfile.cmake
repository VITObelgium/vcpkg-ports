set(MAJOR 4)
set(MINOR 4)
set(REVISION 4)
set(VERSION ${MAJOR}.${MINOR}.${REVISION})
set(PACKAGE_NAME v${VERSION})
set(PACKAGE ${PACKAGE_NAME}.tar.gz)

include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Unidata/netcdf-fortran
    REF v4.5.2
    SHA512 d9f5463ee31dab62d5a1b2feb0c780c344978f179237cd23f92ea32a4b400910a66a9ac4e446be734166ecc7578ef25a7183b4444926a6f386d9a5e02d1cf4f6
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

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin ${CURRENT_PACKAGES_DIR}/bin)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/CMakeFiles)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYRIGHT DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/FindnetCDFFortran.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/cmake)
