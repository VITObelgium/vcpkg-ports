set(VERSION_MAJOR 0)
set(VERSION_MINOR 54)
set(VERSION v${VERSION_MAJOR}.${VERSION_MINOR})

include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO matthijs/${PORT}
    REF 356c3562c818cec22cfb31b70abff0016a2997f1#diff-1f36465ef24298c0c0e565c49fa0b34e
    SHA512 c19c89a8e91f1323dcef73c714b3dddf69cb7606d0bb841d9bd9529a1ff0c29489c6260f2e38209acb18da19054d8ec6278c27232b0e18a6ffa4ce5079565628
    HEAD_REF master
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/disable-shared.patch
        ${CMAKE_CURRENT_LIST_DIR}/win-preprocessor.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DENABLE_TESTS=OFF
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/sqlpp-connector-postgresql)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/cmake)

vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
