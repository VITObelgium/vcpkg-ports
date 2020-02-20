# Defines the MapboxGL::core target
# Defines the MapboxGL::filesource target
# Defines the MapboxGL::qmapboxgl target

include(FindPackageHandleStandardArgs)

find_path(MapboxGL_INCLUDE_DIR
    NAMES mbgl/style/style.hpp
    HINTS ${MapboxGL_ROOT_DIR}/include ${MapboxGL_INCLUDEDIR}
)

find_library(MapboxGL_core_LIBRARY NAMES mbgl-core HINTS ${MapboxGL_ROOT_DIR}/lib)
find_library(MapboxGL_core_LIBRARY_DEBUG NAMES mbgl-cored HINTS ${MapboxGL_ROOT_DIR}/debug/lib ${MapboxGL_ROOT_DIR}/lib)
message(STATUS "MapboxGL core library: ${MapboxGL_core_LIBRARY}")

find_library(MapboxGL_nunicode_LIBRARY NAMES mbgl-vendor-nunicode HINTS ${MapboxGL_ROOT_DIR}/lib)
find_library(MapboxGL_nunicode_LIBRARY_DEBUG NAMES mbgl-vendor-nunicoded HINTS ${MapboxGL_ROOT_DIR}/debug/lib ${MapboxGL_ROOT_DIR}/lib)
message(STATUS "MapboxGL nunicode library: ${MapboxGL_nunicode_LIBRARY}")

find_library(MapboxGL_qt_LIBRARY NAMES qmapboxgl HINTS ${MapboxGL_ROOT_DIR}/lib)
find_library(MapboxGL_qt_LIBRARY_DEBUG NAMES qmapboxgld HINTS ${MapboxGL_ROOT_DIR}/debug/lib ${MapboxGL_ROOT_DIR}/lib)
message(STATUS "MapboxGL qt library: ${MapboxGL_qt_LIBRARY_DEBUG}")

find_package(ZLIB REQUIRED QUIET)
find_package(ICU COMPONENTS i18n uc REQUIRED)
find_package(sqlite3 CONFIG REQUIRED)

find_package_handle_standard_args(MapboxGL
    FOUND_VAR MapboxGL_FOUND
    REQUIRED_VARS
        MapboxGL_INCLUDE_DIR
        MapboxGL_core_LIBRARY
        MapboxGL_nunicode_LIBRARY
        ZLIB_FOUND
        ICU_FOUND
)

mark_as_advanced(
    MapboxGL_ROOT_DIR
    MapboxGL_INCLUDE_DIR
    MapboxGL_core_LIBRARY
    MapboxGL_core_LIBRARY_DEBUG
    MapboxGL_nunicode_LIBRARY
    MapboxGL_nunicode_LIBRARY_DEBUG
    MapboxGL_qt_LIBRARY
    MapboxGL_qt_LIBRARY_DEBUG
    MapboxGL_qgeoplugin_LIBRARY
    MapboxGL_qgeoplugin_LIBRARY_DEBUG
)

if(MapboxGL_FOUND AND NOT TARGET MapboxGL::core)
    add_library(MapboxGL::nunicode STATIC IMPORTED)
    set_target_properties(MapboxGL::nunicode PROPERTIES
        IMPORTED_LINK_INTERFACE_LANGUAGES "CXX"
        INTERFACE_INCLUDE_DIRECTORIES "${MapboxGL_INCLUDE_DIR}"
        IMPORTED_LOCATION ${MapboxGL_nunicode_LIBRARY}
    )

    if(MapboxGL_nunicode_LIBRARY_DEBUG)
        set_target_properties(MapboxGL::nunicode PROPERTIES
            IMPORTED_LOCATION_DEBUG "${MapboxGL_nunicode_LIBRARY_DEBUG}"
        )
    endif()

    add_library(MapboxGL::core STATIC IMPORTED)
    set_target_properties(MapboxGL::core PROPERTIES
        IMPORTED_LINK_INTERFACE_LANGUAGES "CXX"
        INTERFACE_INCLUDE_DIRECTORIES "${MapboxGL_INCLUDE_DIR}"
        INTERFACE_LINK_LIBRARIES "MapboxGL::nunicode;sqlite3;ICU::i18n;ICU::uc;ZLIB::ZLIB"
        IMPORTED_LOCATION ${MapboxGL_core_LIBRARY}
    )

    if(MapboxGL_core_LIBRARY_DEBUG)
        set_target_properties(MapboxGL::core PROPERTIES
            IMPORTED_LOCATION_DEBUG "${MapboxGL_core_LIBRARY_DEBUG}"
        )
    endif()

    # required dependencies
    set_property(TARGET MapboxGL::core APPEND PROPERTY INTERFACE_LINK_LIBRARIES )
endif()

if(MapboxGL_qt_LIBRARY AND NOT TARGET MapboxGL::qmapboxgl)
    add_library(MapboxGL::qmapboxgl STATIC IMPORTED)
    set_target_properties(MapboxGL::qmapboxgl PROPERTIES
        IMPORTED_LINK_INTERFACE_LANGUAGES "CXX"
        INTERFACE_INCLUDE_DIRECTORIES "${MapboxGL_INCLUDE_DIR}"
        IMPORTED_LOCATION ${MapboxGL_qt_LIBRARY}
        INTERFACE_LINK_LIBRARIES MapboxGL::core
        INTERFACE_COMPILE_DEFINITIONS QT_MAPBOXGL_STATIC
    )

    if(MapboxGL_qt_LIBRARY_DEBUG)
        set_target_properties(MapboxGL::qmapboxgl PROPERTIES
            IMPORTED_LOCATION_DEBUG "${MapboxGL_qt_LIBRARY_DEBUG}"
        )
    endif()
endif()
