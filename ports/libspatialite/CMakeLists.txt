cmake_minimum_required(VERSION 3.15)
include(CMakeDependentOption)

project(libspatialite
    VERSION 5.0.1
    LANGUAGES C
    HOMEPAGE_URL "https://www.gaia-gis.it/fossil/libspatialite/index"
)

enable_testing()

include(GNUInstallDirs)
include(CheckIncludeFile)
include(CheckCSourceCompiles)
include(CheckStructHasMember)
include(CheckFunctionExists)
include(CheckSymbolExists)
include(CMakePackageConfigHelpers)

set(CMAKE_EXPORT_COMPILE_COMMANDS 1)

option(ENABLE_GCP "Enable GCP support" ON)
option(ENABLE_GEOPACKAGE "Enable GeoPackage support" ON)
option(ENABLE_LIBXML2 "Enable libxml2 support" ON)
option(ENABLE_FREEXL "Enable freexl support" OFF)
option(ENABLE_RTTOPO "Enable rttopo support" OFF)
option(GEOS_ADVANCED "Enable geos advanced support" OFF)
option(GEOS_TRUNK "Enable geos trunk experimental support" OFF)
option(INSTALL_DATA_FILES "Install the data files" ON)
option(BUILD_EXAMPLES "Build the examples" ON)

if ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
    add_compile_options (-fdiagnostics-color=always)
elseif ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
    add_compile_options (-fcolor-diagnostics)
endif ()

find_package(Iconv REQUIRED)
find_package(LibXml2 REQUIRED)
find_package(GEOS CONFIG REQUIRED)
find_package(unofficial-sqlite3 CONFIG REQUIRED)
find_package(ZLIB REQUIRED)
find_package(PROJ CONFIG REQUIRED)
find_package(Threads REQUIRED)

if (ENABLE_FREEXL)
    find_package(Freexl REQUIRED)
endif ()

if (Iconv_FOUND)
    set(HAVE_ICONV_H)
endif ()

if (Geos_FOUND)
    set(HAVE_GEOS_C_H TRUE)
endif ()

if (Freexl_FOUND)
    set(HAVE_FREEXL_H TRUE)
else ()
    set (OMIT_FREEXL TRUE)
endif ()

set(HAVE_SQLITE3_H TRUE)
set(HAVE_LIBSQLITE3 TRUE)
set(HAVE_LIBZ TRUE)
set(HAVE_PROJ_H TRUE)
set(HAVE_ZIB_H TRUE)

if (NOT MSVC)
    set (CHECK_HEADERS
        dlfcn.h
        fcntl.h
        float.h
        inttypes.h
        math.h
        memory.h
        sqlite3ext.h
        stddef.h
        stdint.h
        stdio.h
        stdlib.h
        strings.h
        string.h
        sys/stat.h
        sys/time.h
        sys/types.h
        unistd.h
    )

    set (CHECK_FUNCTIONS
        fdatasync
        ftruncate
        getcwd
        gettimeofday
        localtime_r
        memmove
        memset
        sqrt
        strcasecmp
        strerror
        strftime
        strncasecmp
        strstr
    )
    
    foreach(FUNC IN LISTS CHECK_FUNCTIONS)
        string(TOUPPER ${FUNC} FUNC_UPPER)
        check_function_exists(${FUNC} HAVE_${FUNC_UPPER})
    endforeach()

    foreach(HDR IN LISTS CHECK_HEADERS)
        string(TOUPPER ${HDR} HDR_UPPER)
        string(REPLACE "." "_" HDR_UPPER ${HDR_UPPER})
        string(REPLACE "/" "_" HDR_UPPER ${HDR_UPPER})
        check_include_file(${HDR} HAVE_${HDR_UPPER})
    endforeach()

    set(STDC_HEADERS HAVE_STDLIB_H)
    set(_LARGEFILE_SOURCE TRUE)
    set(_FILE_OFFSET_BITS 64)
    set(_LARGE_FILE TRUE)
    set(PACKAGE_BUGREPORT "a.furieri@lqt.it")

    check_struct_has_member(tm tm_sec "time.h" TM_IN_TIME)
    if (NOT TM_IN_TIME)
        set(TM_IN_SYS_TIME TRUE)
    endif ()

    check_symbol_exists(SQLITE_INDEX_CONSTRAINT_LIKE "sqlite3.h" HAVE_DECL_SQLITE_INDEX_CONSTRAINT_LIKE)
    
    check_c_source_compiles("
        #include <sys/types.h>
        #include <sys/time.h>
        #include <time.h>

        int main ()
        {
            if ((struct tm *) 0)
                return 0;

            return 0;
        }" TIME_WITH_SYS_TIME
    )
endif ()

add_library(spatialitecommon OBJECT
    src/connection_cache/alloc_cache.c
    src/connection_cache/gg_sequence.c

    src/control_points/gaia_control_points.c
    src/control_points/grass_crs3d.c
    src/control_points/grass_georef_tps.c
    src/control_points/grass_georef.c

    src/cutter/gaia_cutter.c

    src/dxf/dxf_load_distinct.c
    src/dxf/dxf_load_mixed.c
    src/dxf/dxf_loader.c
    src/dxf/dxf_parser.c
    src/dxf/dxf_writer.c

    src/gaiaaux/gg_sqlaux.c
    src/gaiaaux/gg_utf8.c

    src/gaiaexif/gaia_exif.c

    src/gaiageo/gg_advanced.c
    src/gaiageo/gg_endian.c
    src/gaiageo/gg_ewkt.c
    src/gaiageo/gg_extras.c
    src/gaiageo/gg_geoJSON.c
    src/gaiageo/gg_geodesic.c
    src/gaiageo/gg_geometries.c
    src/gaiageo/gg_geoscvt.c
    src/gaiageo/gg_gml.c
    src/gaiageo/gg_kml.c
    src/gaiageo/gg_matrix.c
    src/gaiageo/gg_relations.c
    src/gaiageo/gg_relations_ext.c
    src/gaiageo/gg_rttopo.c
    src/gaiageo/gg_shape.c
    src/gaiageo/gg_transform.c
    src/gaiageo/gg_vanuatu.c
    src/gaiageo/gg_voronoj.c
    src/gaiageo/gg_wkb.c
    src/gaiageo/gg_wkt.c
    src/gaiageo/gg_xml.c

    src/md5/md5.c
    src/md5/gaia_md5.c

    src/shapefiles/shapefiles.c
    src/shapefiles/validator.c

    src/spatialite/create_routing.c
    src/spatialite/dbobj_scopes.c
    src/spatialite/extra_tables.c
    src/spatialite/mbrcache.c
    src/spatialite/metatables.c
    src/spatialite/pause.c
    src/spatialite/se_helpers.c
    src/spatialite/spatialite.c
    src/spatialite/spatialite_init.c
    src/spatialite/srid_aux.c
    src/spatialite/statistics.c
    src/spatialite/table_cloner.c
    src/spatialite/virtualXL.c
    src/spatialite/virtualbbox.c
    src/spatialite/virtualdbf.c
    src/spatialite/virtualelementary.c
    src/spatialite/virtualfdo.c
    src/spatialite/virtualgeojson.c
    src/spatialite/virtualgpkg.c
    src/spatialite/virtualknn.c
    src/spatialite/virtualnetwork.c
    src/spatialite/virtualrouting.c
    src/spatialite/virtualshape.c
    src/spatialite/virtualspatialindex.c
    src/spatialite/virtualxpath.c

    src/srsinit/epsg_inlined_00.c
    src/srsinit/epsg_inlined_01.c
    src/srsinit/epsg_inlined_02.c
    src/srsinit/epsg_inlined_03.c
    src/srsinit/epsg_inlined_04.c
    src/srsinit/epsg_inlined_05.c
    src/srsinit/epsg_inlined_06.c
    src/srsinit/epsg_inlined_07.c
    src/srsinit/epsg_inlined_08.c
    src/srsinit/epsg_inlined_09.c
    src/srsinit/epsg_inlined_10.c
    src/srsinit/epsg_inlined_11.c
    src/srsinit/epsg_inlined_12.c
    src/srsinit/epsg_inlined_13.c
    src/srsinit/epsg_inlined_14.c
    src/srsinit/epsg_inlined_15.c
    src/srsinit/epsg_inlined_16.c
    src/srsinit/epsg_inlined_17.c
    src/srsinit/epsg_inlined_18.c
    src/srsinit/epsg_inlined_19.c
    src/srsinit/epsg_inlined_20.c
    src/srsinit/epsg_inlined_21.c
    src/srsinit/epsg_inlined_22.c
    src/srsinit/epsg_inlined_23.c
    src/srsinit/epsg_inlined_24.c
    src/srsinit/epsg_inlined_25.c
    src/srsinit/epsg_inlined_26.c
    src/srsinit/epsg_inlined_27.c
    src/srsinit/epsg_inlined_28.c
    src/srsinit/epsg_inlined_29.c
    src/srsinit/epsg_inlined_30.c
    src/srsinit/epsg_inlined_31.c
    src/srsinit/epsg_inlined_32.c
    src/srsinit/epsg_inlined_33.c
    src/srsinit/epsg_inlined_34.c
    src/srsinit/epsg_inlined_35.c
    src/srsinit/epsg_inlined_36.c
    src/srsinit/epsg_inlined_37.c
    src/srsinit/epsg_inlined_38.c
    src/srsinit/epsg_inlined_39.c
    src/srsinit/epsg_inlined_40.c
    src/srsinit/epsg_inlined_41.c
    src/srsinit/epsg_inlined_42.c
    src/srsinit/epsg_inlined_43.c
    src/srsinit/epsg_inlined_44.c
    src/srsinit/epsg_inlined_45.c
    src/srsinit/epsg_inlined_46.c
    src/srsinit/epsg_inlined_47.c
    src/srsinit/epsg_inlined_48.c
    src/srsinit/epsg_inlined_49.c
    src/srsinit/epsg_inlined_50.c
    src/srsinit/epsg_inlined_51.c
    src/srsinit/epsg_inlined_52.c
    src/srsinit/epsg_inlined_53.c
    src/srsinit/epsg_inlined_54.c
    src/srsinit/epsg_inlined_55.c
    src/srsinit/epsg_inlined_56.c
    src/srsinit/epsg_inlined_57.c
    src/srsinit/epsg_inlined_58.c
    src/srsinit/epsg_inlined_59.c
    src/srsinit/epsg_inlined_extra.c
    src/srsinit/epsg_inlined_prussian.c
    src/srsinit/epsg_inlined_wgs84_00.c
    src/srsinit/epsg_inlined_wgs84_01.c
    src/srsinit/srs_init.c
    
    src/stored_procedures/stored_procedures.c

    src/topology/gaia_topology.c
    src/topology/gaia_auxtopo.c
    src/topology/gaia_auxtopo_table.c
    src/topology/gaia_topostmts.c
    src/topology/topo_callbacks.c
    src/topology/lwn_network.c
    src/topology/gaia_network.c
    src/topology/gaia_auxnet.c
    src/topology/gaia_netstmts.c
    src/topology/net_callbacks.c

    src/virtualtext/virtualtext.c

    src/wfs/wfs_in.c
)

if (ENABLE_GEOPACKAGE)
    target_sources(spatialitecommon PRIVATE
        src/geopackage/gaia_cvt_gpkg.c
        src/geopackage/gpkgAddGeometryColumn.c
        src/geopackage/gpkgBinary.c
        src/geopackage/gpkgCreateBaseTables.c
        src/geopackage/gpkgCreateTilesTable.c
        src/geopackage/gpkgCreateTilesZoomLevel.c
        src/geopackage/gpkgGetImageType.c
        src/geopackage/gpkgInsertEpsgSRID.c
        src/geopackage/gpkgMakePoint.c
        src/geopackage/gpkg_add_geometry_triggers.c
        src/geopackage/gpkg_add_spatial_index.c
        src/geopackage/gpkg_add_tile_triggers.c
        src/geopackage/gpkg_get_normal_row.c
        src/geopackage/gpkg_get_normal_zoom.c
    )
endif ()

target_compile_definitions(spatialitecommon PRIVATE $<$<C_COMPILER_ID:MSVC>:YY_NO_UNISTD_H>)

target_include_directories(spatialitecommon PRIVATE
PUBLIC
    $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/src/headers>
    $<BUILD_INTERFACE:${CMAKE_BINARY_DIR}>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
PRIVATE
    $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/src/topology>
)

target_link_libraries(spatialitecommon 
PUBLIC
    unofficial::sqlite3::sqlite3
PRIVATE
    ${CMAKE_DL_LIBS}
    Threads::Threads
    LibXml2::LibXml2
    GEOS::geos_c
    PROJ::proj
    ZLIB::ZLIB
    Iconv::Iconv
    $<TARGET_NAME_IF_EXISTS:freexl::freexl>
)

add_library(spatialite $<TARGET_OBJECTS:spatialitecommon> src/versioninfo/version.c)
target_link_libraries(spatialite PUBLIC spatialitecommon)

add_library(mod_spatialite $<TARGET_OBJECTS:spatialite> src/versioninfo/version.c)
target_compile_definitions(mod_spatialite PUBLIC LOADABLE_EXTENSION)
set_property(TARGET mod_spatialite PROPERTY PREFIX "")
target_link_libraries(mod_spatialite PRIVATE spatialitecommon)

if (BUILD_EXAMPLES)
    add_executable(demo1 examples/demo1.c)
    target_link_libraries(demo1 PRIVATE spatialite stdc++)
endif ()

set(INSTALL_CONFIGDIR ${CMAKE_INSTALL_LIBDIR}/cmake/libspatialite)
write_basic_package_version_file("libspatialiteConfigVersion.cmake"
    VERSION ${libspatialite_VERSION}
    COMPATIBILITY SameMajorVersion
)

configure_package_config_file(${CMAKE_SOURCE_DIR}/libspatialiteConfig.cmake.in
    ${CMAKE_CURRENT_BINARY_DIR}/libspatialiteConfig.cmake
    INSTALL_DESTINATION ${INSTALL_CONFIGDIR}
)

install(TARGETS spatialite mod_spatialite spatialitecommon EXPORT spatialite-targets
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)

install(EXPORT spatialite-targets
    FILE libspatialiteTargets.cmake
    NAMESPACE libspatialite::
    DESTINATION ${INSTALL_CONFIGDIR}
)

install(FILES
    ${CMAKE_CURRENT_BINARY_DIR}/libspatialiteConfig.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/libspatialiteConfigVersion.cmake
    DESTINATION ${INSTALL_CONFIGDIR}
)

if (INSTALL_DATA_FILES)
    install(DIRECTORY
        ${CMAKE_CURRENT_SOURCE_DIR}/src/headers/
        DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
        FILES_MATCHING
            PATTERN "*.h"
            PATTERN "*_private.h" EXCLUDE
    )

    if (WIN32 AND NOT MINGW)
        install(FILES
            ${CMAKE_BINARY_DIR}/spatialite/gaiaconfig-msvc.h
            DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/spatialite
        )
    else ()
        install(FILES
            ${CMAKE_BINARY_DIR}/spatialite/gaiaconfig.h
            DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/spatialite
        )
    endif ()
endif ()

if (WIN32 AND NOT MINGW)
    configure_file(config-msvc.h.in ${CMAKE_BINARY_DIR}/config-msvc.h)
    configure_file(src/headers/spatialite/gaiaconfig-msvc.h.in ${CMAKE_BINARY_DIR}/spatialite/gaiaconfig-msvc.h)
else ()
    configure_file(config.h.cmake.in ${CMAKE_BINARY_DIR}/config.h)
    configure_file(src/headers/spatialite/gaiaconfig.h.in ${CMAKE_BINARY_DIR}/spatialite/gaiaconfig.h)
endif ()

