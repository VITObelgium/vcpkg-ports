vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DaanDeMeyer/reproc
    REF v14.0.0
    SHA512 ad58c3cae707406be37068224d463c6f584fcba8282f0532feea4d64a1fa6f7d3586662242ce3f30d9e1b84b66a54bd7aea9a0f420db78dec2ff347f297b5c6e
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DREPROC++=ON
        -DREPROC_MULTITHREADED=ON
        -DREPROC_INSTALL_PKGCONFIG=OFF
        -DREPROC_INSTALL_CMAKECONFIGDIR=share
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

foreach(TARGET reproc reproc++)
    vcpkg_fixup_cmake_targets(
        CONFIG_PATH share/${TARGET} 
        TARGET_PATH share/${TARGET}
    )
endforeach()

file(
    INSTALL ${SOURCE_PATH}/LICENSE 
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}
    RENAME copyright
)
