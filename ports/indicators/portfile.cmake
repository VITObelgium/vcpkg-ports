# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO p-ranav/indicators
    REF v2.2
    SHA512 7ced2d3c320d51c7e0569104744730c8e2f952350bcae214a9781eb43ef4002c8314937db78461351741fc4c3aee7a1364582b1274991e95eb30006a5f2a7ef9
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DINDICATORS_BUILD_TESTS=OFF
        -DINDICATORS_SAMPLES=OFF
        -DINDICATORS_DEMO=OFF
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/indicators)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug ${CURRENT_PACKAGES_DIR}/lib)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(INSTALL ${SOURCE_PATH}/LICENSE.termcolor DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})