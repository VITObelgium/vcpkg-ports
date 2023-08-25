vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fmtlib/fmt
    REF 10.1.0
    SHA512 69a7b8584f828528e3bb4b87153449e96df29bd740adcd42a2e3d50ae4a270c80a5eb2c3057337048be5b978094d8bb73bec3378e3b6370748de2b063dd0aa4b
    HEAD_REF master
    PATCHES
        fix-write-batch.patch
        fix-format-conflict.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DFMT_CMAKE_DIR=share/fmt
        -DFMT_TEST=OFF
        -DFMT_DOC=OFF
)

vcpkg_cmake_install()
file(INSTALL "${SOURCE_PATH}/LICENSE.rst" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    if(VCPKG_TARGET_IS_WINDOWS)
        if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
            if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/lib/fmtd.dll")
                file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/bin")
                file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/fmtd.dll" "${CURRENT_PACKAGES_DIR}/debug/bin/fmtd.dll")
            endif()
        endif()
        if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
            if(EXISTS "${CURRENT_PACKAGES_DIR}/lib/fmt.dll")
                file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/bin")
                file(RENAME "${CURRENT_PACKAGES_DIR}/lib/fmt.dll" "${CURRENT_PACKAGES_DIR}/bin/fmt.dll")
            endif()
        endif()
    endif()

    vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/include/fmt/core.h
        "defined(FMT_SHARED)"
        "1"
    )
endif()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_cmake_config_fixup()
vcpkg_fixup_pkgconfig()

if(VCPKG_TARGET_IS_WINDOWS)
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/share/fmt/fmt-targets-debug.cmake
            "lib/fmtd.dll"
            "bin/fmtd.dll"
        )
    endif()
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/share/fmt/fmt-targets-release.cmake
            "lib/fmt.dll"
            "bin/fmt.dll"
        )
    endif()
endif()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Handle post-build CMake instructions
vcpkg_copy_pdbs()
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
