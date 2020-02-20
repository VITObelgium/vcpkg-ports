include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO intel/parallelstl
    REF 20190321
    SHA512 814f98f8c9c4203425eda34b69d16fd2a6ad36a5f8d21b2745f5a8f87372ce43830f92e3e058cb3fdf2e942b9e6256df11abe514658b25fbbe553b6c2bb96e54
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