include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fmtlib/fmt
    REF 6.2.0
    SHA512 0003543f437bae416600a2b982eb133f65588bd36d7506fa7d883ae3133fcaf7ad825904af9b588ea22e5d91e56560aaf4243a6afa11ff6d8aace2e4bb1b0cee
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DFMT_CMAKE_DIR=share/fmt
        -DFMT_TEST=OFF
        -DFMT_DOC=OFF
)

vcpkg_install_cmake()
file(INSTALL ${SOURCE_PATH}/LICENSE.rst DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/bin)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/fmt.dll ${CURRENT_PACKAGES_DIR}/bin/fmt.dll)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/fmtd.dll ${CURRENT_PACKAGES_DIR}/debug/bin/fmtd.dll)

    # Force FMT_SHARED to 1
    file(READ ${CURRENT_PACKAGES_DIR}/include/fmt/core.h FMT_CORE_H)
    string(REPLACE "defined(FMT_SHARED)" "1" FMT_CORE_H "${FMT_CORE_H}")
    file(WRITE ${CURRENT_PACKAGES_DIR}/include/fmt/core.h "${FMT_CORE_H}")
endif()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_fixup_cmake_targets()

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    file(READ ${CURRENT_PACKAGES_DIR}/share/fmt/fmt-targets-debug.cmake FMT_DEBUG_MODULE)
    string(REPLACE "lib/fmtd.dll" "bin/fmtd.dll" FMT_DEBUG_MODULE ${FMT_DEBUG_MODULE})
    file(WRITE ${CURRENT_PACKAGES_DIR}/share/fmt/fmt-targets-debug.cmake "${FMT_DEBUG_MODULE}")
    file(READ ${CURRENT_PACKAGES_DIR}/share/fmt/fmt-targets-release.cmake FMT_RELEASE_MODULE)
    string(REPLACE "lib/fmt.dll" "bin/fmt.dll" FMT_RELEASE_MODULE ${FMT_RELEASE_MODULE})
    file(WRITE ${CURRENT_PACKAGES_DIR}/share/fmt/fmt-targets-release.cmake "${FMT_RELEASE_MODULE}")
endif ()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

vcpkg_copy_pdbs()
vcpkg_test_cmake(PACKAGE_NAME fmt REQUIRED_HEADER fmt/format.h TARGETS fmt::fmt)