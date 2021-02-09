vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO VITObelgium/cpp-infra
    REF 0.9.56
    HEAD_REF master
    SHA512 0797a5836ea15ff3cfb561b13ef22277614e1b387c84947875a289cf62a82f0ac8c01a95a7ff8d2f9ce10e5fae7ab3c8a06fe7090eeb26cffd7a816467b689b5
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
