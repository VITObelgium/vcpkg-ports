vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO VITObelgium/cpp-infra
    REF 0.11.0
    HEAD_REF master
    SHA512 2b8737b6bb1b007dafd3db570b1d0d1c7f975d260d880360e8d4d866910abb38c064f1983b6f8546c54b4bbf3dc94c733d602a034fbadc35dd530235c716b853
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES 
        gdal        INFRA_GDAL
        gdal        INFRA_EMBED_GDAL_DATA
        zstd        INFRA_COMPRESSION_ZSTD
        xml         INFRA_XML
        log         INFRA_LOGGING
        numeric     INFRA_NUMERIC
        process     INFRA_PROCESS
        cliprogress INFRA_CLI_PROGRESS
        sqlite      INFRA_DATABASE
        sqlite      INFRA_DATABASE_SQLITE
        postgres    INFRA_DATABASE_POSTGRES
        charset     INFRA_CHARSET
        testutils   INFRA_ENABLE_TEST_UTILS
        ui          INFRA_UI_COMPONENTS
        qml         INFRA_UI_COMPONENTS_QML
        location    INFRA_UI_COMPONENTS_LOCATION
        xlsx        INFRA_UI_COMPONENTS_XLSX_EXPORT
)

set (OPTIONAL_OPTIONS "")
if ("ui" IN_LIST FEATURES AND APPLE)
    # make sure we can find gl headers on OSX
    set (OPTIONAL_OPTIONS -DVCPKG_ALLOW_SYSTEM_LIBS=ON)
endif ()

if ("zstd" IN_LIST FEATURES)
    list (APPEND OPTIONAL_OPTIONS -DINFRA_COMPRESSION=ON)
endif ()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        ${FEATURE_OPTIONS}
        -DINFRA_LICENSE_MANAGER=OFF
        -DINFRA_ENABLE_TESTS=OFF
        -DINFRA_ENABLE_BENCHMARKS=OFF
        -DINFRA_ENABLE_DOCUMENTATION=OFF
        ${OPTIONAL_OPTIONS}
)

vcpkg_install_cmake()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/infra")
vcpkg_copy_pdbs()
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
