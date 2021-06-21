vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO oneapi-src/oneDPL 
    REF 20190321
    SHA512 2d6e2347019bf4bde8a5d397258f1392e14b064238024727ee95dab5d945e9b4a1ffe0c519cf3fcbc4b0d2835fb6a2c473c383f42892b670d99cc56b28081646
    HEAD_REF master
    PATCHES install-targets.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
vcpkg_test_cmake(PACKAGE_NAME ParallelSTL)