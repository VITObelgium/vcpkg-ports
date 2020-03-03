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

find_library(MapboxGL_csscolorparser_LIBRARY NAMES mbgl-vendor-csscolorparser HINTS ${MapboxGL_ROOT_DIR}/lib)
find_library(MapboxGL_csscolorparser_LIBRARY_DEBUG NAMES mbgl-vendor-csscolorparserd HINTS ${MapboxGL_ROOT_DIR}/debug/lib ${MapboxGL_ROOT_DIR}/lib)
message(STATUS "MapboxGL csscolorparser library: ${MapboxGL_csscolorparser_LIBRARY}")

find_library(MapboxGL_parsedate_LIBRARY NAMES mbgl-vendor-parsedate HINTS ${MapboxGL_ROOT_DIR}/lib)
find_library(MapboxGL_parsedate_LIBRARY_DEBUG NAMES mbgl-vendor-parsedated HINTS ${MapboxGL_ROOT_DIR}/debug/lib ${MapboxGL_ROOT_DIR}/lib)
message(STATUS "MapboxGL parsedate library: ${MapboxGL_parsedate_LIBRARY}")

find_package(ZLIB REQUIRED QUIET)
find_package(ICU COMPONENTS i18n uc REQUIRED)
find_package(sqlite3 CONFIG REQUIRED)

find_package_handle_standard_args(MapboxGL
    FOUND_VAR MapboxGL_FOUND
    REQUIRED_VARS
        MapboxGL_INCLUDE_DIR
        MapboxGL_core_LIBRARY
        MapboxGL_nunicode_LIBRARY
        MapboxGL_csscolorparser_LIBRARY
        MapboxGL_parsedate_LIBRARY
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
    MapboxGL_csscolorparser_LIBRARY
    MapboxGL_csscolorparser_LIBRARY_DEBUG
    MapboxGL_parsedate_LIBRARY
    MapboxGL_parsedate_LIBRARY_DEBUG
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

    add_library(MapboxGL::csscolorparser STATIC IMPORTED)
    set_target_properties(MapboxGL::csscolorparser PROPERTIES
        IMPORTED_LINK_INTERFACE_LANGUAGES "CXX"
        INTERFACE_INCLUDE_DIRECTORIES "${MapboxGL_INCLUDE_DIR}"
        IMPORTED_LOCATION ${MapboxGL_csscolorparser_LIBRARY}
    )

    if(MapboxGL_csscolorparser_LIBRARY_DEBUG)
        set_target_properties(MapboxGL::csscolorparser PROPERTIES
            IMPORTED_LOCATION_DEBUG "${MapboxGL_csscolorparser_LIBRARY_DEBUG}"
        )
    endif()

    add_library(MapboxGL::parsedate STATIC IMPORTED)
    set_target_properties(MapboxGL::parsedate PROPERTIES
        IMPORTED_LINK_INTERFACE_LANGUAGES "CXX"
        INTERFACE_INCLUDE_DIRECTORIES "${MapboxGL_INCLUDE_DIR}"
        IMPORTED_LOCATION ${MapboxGL_parsedate_LIBRARY}
    )

    if(MapboxGL_parsedate_LIBRARY_DEBUG)
        set_target_properties(MapboxGL::parsedate PROPERTIES
            IMPORTED_LOCATION_DEBUG "${MapboxGL_parsedate_LIBRARY_DEBUG}"
        )
    endif()

    add_library(MapboxGL::core STATIC IMPORTED)
    set_target_properties(MapboxGL::core PROPERTIES
        IMPORTED_LINK_INTERFACE_LANGUAGES "CXX"
        INTERFACE_INCLUDE_DIRECTORIES "${MapboxGL_INCLUDE_DIR}"
        INTERFACE_LINK_LIBRARIES "MapboxGL::nunicode;MapboxGL::csscolorparser;MapboxGL::parsedate;sqlite3;ICU::i18n;ICU::uc;ZLIB::ZLIB"
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
