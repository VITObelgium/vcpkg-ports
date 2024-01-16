vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO oneapi-src/oneDPL
    REF oneDPL-2022.3.0-rc1
    SHA512 601ad69014c56c7601a936456b17e7ea157f0764eb93e7e34e74a44b51383a2af2123c43adcd4f8c380a839e661facb3b22eb4780672c2d0261ef16f833c5020
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
