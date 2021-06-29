include(FindPackageHandleStandardArgs)

find_path(Rttopo_INCLUDE_DIR
    NAMES librttopo.h
    HINTS ${Rttopo_ROOT_DIR}/include ${Rttopo_INCLUDEDIR}
)

find_library(Rttopo_LIBRARY NAMES rttopo librttopo HINTS ${Rttopo_ROOT_DIR}/lib)
find_library(Rttopo_LIBRARY_DEBUG NAMES rttopo librttopo HINTS ${Rttopo_ROOT_DIR}/lib)

message(STATUS "Rttopo library: ${Rttopo_LIBRARY}")

find_package_handle_standard_args(Rttopo
    FOUND_VAR Rttopo_FOUND
    REQUIRED_VARS Rttopo_INCLUDE_DIR Rttopo_LIBRARY
)

mark_as_advanced(
    Rttopo_ROOT_DIR
    Rttopo_INCLUDE_DIR
    Rttopo_LIBRARY
    Rttopo_LIBRARY_DEBUG
)

if(Rttopo_FOUND AND NOT TARGET rttopo::rttopo)
    add_library(rttopo::rttopo STATIC IMPORTED)
    set_target_properties(rttopo::rttopo PROPERTIES
        IMPORTED_LINK_INTERFACE_LANGUAGES "C"
        INTERFACE_INCLUDE_DIRECTORIES "${Rttopo_INCLUDE_DIR}"
        IMPORTED_LOCATION ${Rttopo_LIBRARY}
    )

    if(Rttopo_LIBRARY_DEBUG)
        set_target_properties(rttopo::rttopo PROPERTIES
            IMPORTED_LOCATION_DEBUG "${Rttopo_LIBRARY_DEBUG}"
        )
    endif()
endif()
