vcpkg_from_git(
    URL https://github.com/foonathan/type_safe.git
    OUT_SOURCE_PATH SOURCE_PATH
    REF v0.2.1
    HEAD_REF master
    SHA512 0
    RECURSE_SUBMODULES
)

# avoid always building the tests and examples
vcpkg_replace_string(${SOURCE_PATH}/CMakeLists.txt " OR (CMAKE_CURRENT_SOURCE_DIR STREQUAL CMAKE_SOURCE_DIR)" "")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DTYPE_SAFE_BUILD_TEST_EXAMPLE=OFF
)

vcpkg_install_cmake()
file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/FindTypesafe.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/cmake)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)

vcpkg_test_cmake(PACKAGE_NAME Typesafe MODULE)
