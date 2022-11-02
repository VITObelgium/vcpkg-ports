
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pybind/pybind11
    REF v2.10.1
    SHA512 040f109ec870516acdaebc5133ccbba9e3ed7ff93214a66997cf4b8366c209322f3c902c283040826c7e585c3ea2259caf62d90d0b475bfa33d21e459dd54df1
    HEAD_REF master
)

vcpkg_find_acquire_program(PYTHON3)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DPYBIND11_TEST=OFF
        -DPython_EXECUTABLE=${PYTHON3}
        -DPYBIND11_FINDPYTHON=ON
        -DVCPKG_ALLOW_SYSTEM_LIBS=${VCPKG_TARGET_IS_OSX}
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