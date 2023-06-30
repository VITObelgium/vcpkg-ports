vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO bfgroup/Lyra
    REF 1.6.1
    SHA512 643c25fbe996af2e888eacb99a715e3d420dbfc21d48756703cf301ab6ba0d1f8eea1cd0764bd5c173d2ddcef7c799448d8c3a77676024205163305e1363d461
    HEAD_REF master
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
