vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO oneapi-src/oneDPL
    REF oneDPL-2021.4.0-release
    SHA512 97bb14c70770643384089edc28488a05cd778966a986565300c27bae700b9081e1e3c40a82a0f6ec29f1062bf97fd2ba298e6112b144c8ade2a6679db6413b6d
    HEAD_REF master
    PATCHES cmake-config.patch
)

execute_process(
    COMMAND ${CMAKE_COMMAND}
        -DOUTPUT_DIR=${CURRENT_PACKAGES_DIR}/share/${PORT}
        -P ${SOURCE_PATH}/cmake/scripts/generate_config.cmake
    RESULT_VARIABLE CMD_ERROR
)
if (CMD_ERROR)
    message(FATAL_ERROR "Failed to generate oneDPL cmake config files")
endif ()

file(COPY ${SOURCE_PATH}/include/oneapi DESTINATION ${CURRENT_PACKAGES_DIR}/include/)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/licensing/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})

vcpkg_test_cmake(PACKAGE_NAME oneDPL)
