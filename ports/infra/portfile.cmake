vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO VITObelgium/cpp-infra
    REF 0.9.26
    HEAD_REF master
    SHA512 307aaadca723cfa83b86d801202e326875ec85885930af6d22d65fbc959511eeaae8b5b21b9a55f9fbcfc20d3d483058cb1f1153b7ae4457d7e6d407fc622767
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES 
        gdal        INFRA_GDAL
        gdal        INFRA_EMBED_GDAL_DATA
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

if ("ui" IN_LIST FEATURES AND APPLE)
    # make sure we can find gl headers on OSX
    set (OPTIONAL_OPTIONS -DVCPKG_ALLOW_SYSTEM_LIBS=ON)
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
