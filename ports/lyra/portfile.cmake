include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO bfgroup/Lyra
    REF 1.5.1
    SHA512 e349c57614fe18cfee49b6a3977f133de3e567aa6b1c148abf9510432f7db34b75488739850e48c7943a15151fe2eedb129179d8d73eb61fb4f9a11c54b61086
    HEAD_REF master
    PATCHES warnings.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
vcpkg_test_cmake(PACKAGE_NAME lyra REQUIRED_HEADER lyra/lyra.hpp TARGETS bfg::lyra)

#provided for backwards compatibility, remove eventually
file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/FindLyra.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/cmake)
vcpkg_test_cmake(PACKAGE_NAME Lyra MODULE REQUIRED_HEADER lyra/lyra.hpp TARGETS BFG::Lyra)
