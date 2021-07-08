vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO VITObelgium/geodynamix
    REF 0.13.0
    HEAD_REF main
    SHA512 031e66b94fc8229040ef0bde1f4c34b1ac9e4a433b334ff9f5ad511556309602125f78a77f71d402035b590c33e971ec289f58020777e24769fb18deb19da852
)

TEST_FEATURE("testutils" ENABLE_TESTUTILS)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DGDX_ENABLE_TOOLS=OFF
        -DGDX_ENABLE_TESTS=OFF
        -DGDX_ENABLE_OPENMP=OFF
        -DGDX_ENABLE_SIMD=ON
        -DGDX_ENABLE_BENCHMARKS=OFF
        -DGDX_ENABLE_TEST_UTILS=${ENABLE_TESTUTILS}
        -DGDX_PYTHON_BINDINGS=OFF
        -DGDX_INSOURCE_DEPS=OFF
        -DGDX_INSTALL_DEVELOPMENT_FILES=ON
)

vcpkg_install_cmake()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/geodynamix")
vcpkg_copy_pdbs()
vcpkg_test_cmake(PACKAGE_NAME Geodynamix)
file(WRITE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright "Copyright VITO NV\n")
