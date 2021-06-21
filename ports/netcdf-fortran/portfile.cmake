vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Unidata/netcdf-fortran
    REF v4.5.3
    SHA512 fe4b2f6f8c44bf4fdeebe3cbd57ee44ccee15a70075428bb68f0d33b70f9291b68b542965634a27fb4be5a59c756d672a3d264f2628391861edb98a244e072b4
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
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin ${CURRENT_PACKAGES_DIR}/bin)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/CMakeFiles)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYRIGHT DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/FindnetCDFFortran.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/cmake)
