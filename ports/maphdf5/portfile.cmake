include(vcpkg_common_functions)
vcpkg_from_git(
    URL https://git.vito.be/scm/marvin/cpphdf5tools.git
    OUT_SOURCE_PATH SOURCE_PATH
    REF 1.0.2
    HEAD_REF develop
    SHA512 0
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DCPPHDF5_TOOLS_ENABLE_TESTS=OFF
)

vcpkg_install_cmake()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/maphdf5")
vcpkg_copy_pdbs()
file(WRITE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright "Copyright VITO NV\n")

vcpkg_test_cmake(PACKAGE_NAME MapHdf5)