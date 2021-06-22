set(MAJOR 3)
set(MINOR 0)
set(REVISION 24)
set(VERSION v${MAJOR}.${MINOR}.${REVISION})
set(PACKAGE_NAME ${PORT}-${VERSION})
set(PACKAGE ${PACKAGE_NAME}.tar.bz2)

vcpkg_fail_port_install(ON_TARGET "Windows" MESSAGE "Mapnik is not supported on windows")
vcpkg_find_acquire_program(PYTHON3)

# Extract source into architecture specific directory, because GDALs' build currently does not
# support out of source builds.
set(SOURCE_PATH_DEBUG   ${CURRENT_BUILDTREES_DIR}/src-${TARGET_TRIPLET}-debug/${PORT}-${VERSION})
set(SOURCE_PATH_RELEASE ${CURRENT_BUILDTREES_DIR}/src-${TARGET_TRIPLET}-release/${PORT}-${VERSION})

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/${PORT}/${PORT}/releases/download/${VERSION}/${PACKAGE}"
    FILENAME "${PACKAGE}"
    SHA512 5558af3f728462fba4ddd1b00085029d061c686e67c013a0d383ea9cd90c83775c39eb9f29340c2fb8602a4b8193544965d3c5b09f0749a4c00efd483b9be509
)

foreach(BUILD_TYPE debug release)
    set(CONFIG_SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src-${TARGET_TRIPLET}-${BUILD_TYPE})
    file(REMOVE_RECURSE ${CONFIG_SOURCE_PATH})
    vcpkg_extract_source_archive(${ARCHIVE} ${CONFIG_SOURCE_PATH})
    vcpkg_apply_patches(
        SOURCE_PATH ${CONFIG_SOURCE_PATH}/${PACKAGE_NAME}
        PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/mapnik-render-link.patch
        ${CMAKE_CURRENT_LIST_DIR}/tiff-link.patch
        ${CMAKE_CURRENT_LIST_DIR}/icu-link.patch
        ${CMAKE_CURRENT_LIST_DIR}/config-path.patch
        ${CMAKE_CURRENT_LIST_DIR}/gdallib-detection.patch
    )
endforeach()

set(MAPNIK_INPUT_PLUGINS "raster,shape,csv,geojson")

vcpkg_detect_compilers(
    C MAPNIK_C_COMPILER
    CXX MAPNIK_CXX_COMPILER
    FC MAPNIK_FC_COMPILER
    AR MAPNIK_AR
    RANLIB MAPNIK_RANLIB
    LD MAPNIK_LD
)
vcpkg_detect_compiler_flags(
    STANDARD 17
    C_DEBUG MAPNIK_CFLAGS_DEB C_RELEASE MAPNIK_CFLAGS_REL
    CXX_DEBUG MAPNIK_CXXFLAGS_DEB CXX_RELEASE MAPNIK_CXXFLAGS_REL
    LD_DEBUG MAPNIK_LDFLAGS_DEB LD_RELEASE MAPNIK_LDFLAGS_REL
)

set(SCONS_OPTIONS
    CC=${MAPNIK_C_COMPILER}
    CXX=${MAPNIK_CXX_COMPILER}
    LD=${MAPNIK_LD}
    AR=${MAPNIK_AR}
    RANLIB=${MAPNIK_RANLIB}
    PATH=${CURRENT_INSTALLED_DIR}/tools
    BOOST_INCLUDES=${CURRENT_INSTALLED_DIR}/include
    ICU_INCLUDES=${CURRENT_INSTALLED_DIR}/include
    FREETYPE_INCLUDES=${CURRENT_INSTALLED_DIR}/include/freetype2
    HB_INCLUDES=${CURRENT_INSTALLED_DIR}/include
    PROJ_INCLUDES=${CURRENT_INSTALLED_DIR}/include
    PNG_INCLUDES=${CURRENT_INSTALLED_DIR}/include
    TIFF_INCLUDES=${CURRENT_INSTALLED_DIR}/include
    CAIRO=no
    JPEG=no
    WEBP=no
    DEMO=no
    CPP_TESTS=no
    BINDINGS=none
    SHAPEINDEX=no
    MAPNIK_INDEX=no
    PATH_REMOVE=/usr
)

if (${VCPKG_LIBRARY_LINKAGE} STREQUAL "static")
    list(APPEND SCONS_OPTIONS LINKING=static)
    list(APPEND SCONS_OPTIONS PLUGIN_LINKING=static)
else ()
    list(APPEND SCONS_OPTIONS LINKING=shared)
    list(APPEND SCONS_OPTIONS PLUGIN_LINKING=shared)
endif ()

if (${VCPKG_CRT_LINKAGE} STREQUAL "static")
    list(APPEND SCONS_OPTIONS RUNTIME_LINK=static)
else ()
    list(APPEND SCONS_OPTIONS RUNTIME_LINK=shared)
endif ()

if ("gdal" IN_LIST FEATURES)
    list(APPEND SCONS_OPTIONS GDAL_CONFIG=${CURRENT_INSTALLED_DIR}/tools/gdal-config)
    set(MAPNIK_INPUT_PLUGINS "${MAPNIK_INPUT_PLUGINS},gdal")
else ()
    list(APPEND SCONS_OPTIONS GDAL_CONFIG=${CURRENT_INSTALLED_DIR}/tools/invalid-config)
endif ()

list(APPEND SCONS_OPTIONS INPUT_PLUGINS=${MAPNIK_INPUT_PLUGINS})

set(SCONS_OPTIONS_REL
    CUSTOM_CFLAGS=${MAPNIK_CFLAGS_REL}
    CUSTOM_CXXFLAGS=${MAPNIK_CXXFLAGS_REL}
    CUSTOM_LDFLAGS=${MAPNIK_LDFLAGS_REL}
    ${SCONS_OPTIONS}
    DEBUG=no
    PREFIX=${CURRENT_PACKAGES_DIR}
    BOOST_LIBS=${CURRENT_INSTALLED_DIR}/lib
    ICU_LIBS=${CURRENT_INSTALLED_DIR}/lib
    FREETYPE_LIBS=${CURRENT_INSTALLED_DIR}/lib
    HB_LIBS=${CURRENT_INSTALLED_DIR}/lib
    PROJ_LIBS=${CURRENT_INSTALLED_DIR}/lib
    PNG_LIBS=${CURRENT_INSTALLED_DIR}/lib
    TIFF_LIBS=${CURRENT_INSTALLED_DIR}/lib
)

set(SCONS_OPTIONS_DBG
    ${SCONS_OPTIONS}
    DEBUG=yes
    CUSTOM_CFLAGS=${MAPNIK_CFLAGS_DEB}
    CUSTOM_CXXFLAGS=${MAPNIK_CXXFLAGS_DEB}
    CUSTOM_LDFLAGS=${MAPNIK_LDFLAGS_DEB}
    PREFIX=${CURRENT_PACKAGES_DIR}/debug
    BOOST_LIBS=${CURRENT_INSTALLED_DIR}/debug/lib
    ICU_LIBS=${CURRENT_INSTALLED_DIR}/debug/lib
    FREETYPE_LIBS=${CURRENT_INSTALLED_DIR}/debug/lib
    HB_LIBS=${CURRENT_INSTALLED_DIR}/debug/lib
    PROJ_LIBS=${CURRENT_INSTALLED_DIR}/lib
    PNG_LIBS=${CURRENT_INSTALLED_DIR}/debug/lib
    TIFF_LIBS=${CURRENT_INSTALLED_DIR}/debug/lib
)

message(STATUS "Configuring ${TARGET_TRIPLET}-rel")
message(STATUS "${SCONS_OPTIONS_REL}")
vcpkg_execute_required_process(
    COMMAND ${PYTHON3} scons/scons.py configure
    "${SCONS_OPTIONS_REL}"
    WORKING_DIRECTORY ${SOURCE_PATH_RELEASE}
    LOGNAME scons-configure-${TARGET_TRIPLET}-release
)

message(STATUS "Configuring ${TARGET_TRIPLET}-dbg")
vcpkg_execute_required_process(
    COMMAND ${PYTHON3} scons/scons.py configure
    "${SCONS_OPTIONS_DBG}"
    WORKING_DIRECTORY ${SOURCE_PATH_DEBUG}
    LOGNAME scons-configure-${TARGET_TRIPLET}-debug
)

message(STATUS "Building ${TARGET_TRIPLET}-rel")
vcpkg_execute_required_process(
    COMMAND ${PYTHON3} scons/scons.py --jobs=${VCPKG_CONCURRENCY}
    WORKING_DIRECTORY ${SOURCE_PATH_RELEASE}
    LOGNAME scons-build-${TARGET_TRIPLET}-release
)

message(STATUS "Building ${TARGET_TRIPLET}-dbg")
vcpkg_execute_required_process(
    COMMAND ${PYTHON3} scons/scons.py --jobs=${VCPKG_CONCURRENCY}
    WORKING_DIRECTORY ${SOURCE_PATH_DEBUG}
    LOGNAME scons-build-${TARGET_TRIPLET}-debug
)

message(STATUS "Installing ${TARGET_TRIPLET}-rel")
vcpkg_execute_required_process(
    COMMAND ${PYTHON3} scons/scons.py install
    WORKING_DIRECTORY ${SOURCE_PATH_RELEASE}
    LOGNAME scons-install-${TARGET_TRIPLET}-release
)

message(STATUS "Installing ${TARGET_TRIPLET}-dbg")
vcpkg_execute_required_process(
    COMMAND ${PYTHON3} scons/scons.py install
    WORKING_DIRECTORY ${SOURCE_PATH_DEBUG}
    LOGNAME scons-install-${TARGET_TRIPLET}-debug
)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)

file(GLOB BIN_FILES ${CURRENT_PACKAGES_DIR}/bin/*)
file(COPY ${BIN_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/tools)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/mapnik)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/mapnik)

# Handle copyright
file(INSTALL ${SOURCE_PATH_RELEASE}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
