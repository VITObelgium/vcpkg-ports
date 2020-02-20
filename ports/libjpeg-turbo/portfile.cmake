include(vcpkg_common_functions)
set(MAJOR 2)
set(MINOR 0)
set(REVISION 4)
set(VERSION ${MAJOR}.${MINOR}.${REVISION})
set(SHA512_HASH 186b145730759c67b22380c2d64ca207d817cf78f8ded98949bcb087887173de48067ce29cdc1ba08502bd51aa63a5d44652db67beb4d1b2a9d0121566db57c2)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ${PORT}/${PORT}
    REF ${VERSION}
    SHA512 ${SHA512_HASH}
    HEAD_REF master
)

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm" OR VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
    set(LIBJPEGTURBO_SIMD -DWITH_SIMD=OFF)
else()
    set(LIBJPEGTURBO_SIMD -DWITH_SIMD=ON -DREQUIRE_SIMD=ON)
    if (NOT MINGW)
        vcpkg_find_acquire_program(NASM)
        get_filename_component(NASM_EXE_PATH ${NASM} DIRECTORY)
        set(ENV{PATH} "$ENV{PATH};${NASM_EXE_PATH}")
    endif ()
endif()

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    set(ENV{_CL_} "-DNO_GETENV -DNO_PUTENV")
endif()

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" ENABLE_SHARED)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" ENABLE_STATIC)
string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "dynamic" WITH_CRT_DLL)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DENABLE_STATIC=${ENABLE_STATIC}
        -DENABLE_SHARED=${ENABLE_SHARED}
        -DWITH_CRT_DLL=${WITH_CRT_DLL}
        ${LIBJPEGTURBO_SIMD}
    OPTIONS_DEBUG -DINSTALL_HEADERS=OFF
)

vcpkg_install_cmake()
vcpkg_fixup_pkgconfig_file(NAMES libjpeg libturbojpeg)
vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)
    if (EXISTS ${CURRENT_PACKAGES_DIR}/debug/lib/jpeg-staticd.lib)
        file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/jpeg-staticd.lib ${CURRENT_PACKAGES_DIR}/debug/lib/jpegd.lib)
    endif ()

    if (EXISTS ${CURRENT_PACKAGES_DIR}/lib/jpeg-static.lib)
        file(RENAME ${CURRENT_PACKAGES_DIR}/lib/jpeg-static.lib ${CURRENT_PACKAGES_DIR}/lib/jpeg.lib)
    endif ()
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(COPY ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
