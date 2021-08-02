
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pybind/pybind11
    REF v2.7.0
    SHA512 529596c8762f463868f942ca9c4d3e4ed141bc09c734defeeace2b0250234c3359ef1f231997389fbffca849e01ba1feb8d7edc385745b6d964771aa67ced720
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DPYBIND11_TEST=OFF
        -DPYTHONLIBS_FOUND=ON
        -DPYTHON_INCLUDE_DIRS=${CURRENT_INSTALLED_DIR}/include
    OPTIONS_RELEASE
        -DPYTHON_IS_DEBUG=OFF
    OPTIONS_DEBUG
        -DPYTHON_IS_DEBUG=ON
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH share/cmake/${PORT})

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/)

# copy license
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/pybind11/copyright)