
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rollbear/trompeloeil
    REF v42
    SHA512 50f9b517ba08331fe852ca27bc85b370930b3bfbe0e94523953f501d72fd5e53fa2ae12b9176782e49347e04eba038dd59a7013cad88493818330fc16175db25
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_TESTING=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/trompeloeil)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug ${CURRENT_PACKAGES_DIR}/lib)

if(NOT EXISTS ${CURRENT_PACKAGES_DIR}/include/trompeloeil.hpp)
    message(FATAL_ERROR "Main includes have moved. Please update the forwarder.")
endif()

configure_file(${SOURCE_PATH}/LICENSE_1_0.txt ${CURRENT_PACKAGES_DIR}/share/trompeloeil/copyright COPYONLY)
