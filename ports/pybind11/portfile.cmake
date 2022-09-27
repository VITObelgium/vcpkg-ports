
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pybind/pybind11
    REF v2.10.0
    SHA512 93112ce530a0652b2b4458a137b4a35f2fd8607f82ad96698ef422128d0b53e16e1d06c239ee4643b821acafae09c74eb0f72bc4ee5584aa9fcdaff4d79980d9
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