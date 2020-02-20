include(vcpkg_common_functions)

vcpkg_from_git(
    URL https://git.vito.be/scm/marvin-geodynamix/gdx-core.git
    OUT_SOURCE_PATH SOURCE_PATH
    REF 0.9.6
    HEAD_REF develop
    SHA512 0
)

TEST_FEATURE("testutils" ENABLE_TESTUTILS)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DGDX_ENABLE_TOOLS=OFF
        -DGDX_ENABLE_TESTS=OFF
        -DGDX_ENABLE_TEST_UTILS=OFF
        -DGDX_ENABLE_BENCHMARKS=OFF
        -DGDX_ENABLE_TEST_UTILS=${ENABLE_TESTUTILS}
        -DGDX_PYTHON_BINDINGS=OFF
        -DGDX_INSOURCE_DEPS=OFF
        -DGDX_INSTALL_DEVELOPMENT_FILES=ON
)

vcpkg_install_cmake()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/gdx")
vcpkg_copy_pdbs()
vcpkg_test_cmake(PACKAGE_NAME Gdx)
file(WRITE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright "Copyright VITO NV\n")
