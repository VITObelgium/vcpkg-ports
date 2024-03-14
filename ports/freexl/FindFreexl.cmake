include(FindPackageHandleStandardArgs)

find_path(Freexl_INCLUDE_DIR
    NAMES freexl.h
    HINTS ${Freexl_ROOT_DIR}/include ${Freexl_INCLUDEDIR}
)

find_library(Freexl_LIBRARY NAMES freexl HINTS ${Freexl_ROOT_DIR}/lib)
find_library(Freexl_LIBRARY_DEBUG NAMES freexld freexl HINTS ${Freexl_ROOT_DIR}/lib)
find_package(Iconv QUIET REQUIRED)
find_package(unofficial-minizip CONFIG REQUIRED)

find_package_handle_standard_args(Freexl
    FOUND_VAR Freexl_FOUND
    REQUIRED_VARS Freexl_INCLUDE_DIR Freexl_LIBRARY
)

mark_as_advanced(
    Freexl_ROOT_DIR
    Freexl_INCLUDE_DIR
    Freexl_LIBRARY
    Freexl_LIBRARY_DEBUG
)

if(Freexl_FOUND AND NOT TARGET freexl::freexl)
    add_library(freexl::freexl STATIC IMPORTED)
    set_target_properties(freexl::freexl PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${Freexl_INCLUDE_DIR}"
        INTERFACE_LINK_LIBRARIES "Iconv::Iconv;unofficial::minizip::minizip"
        IMPORTED_LOCATION ${Freexl_LIBRARY}
    )

    if(Freexl_LIBRARY_DEBUG)
        set_target_properties(freexl::freexl PROPERTIES
            IMPORTED_LOCATION_DEBUG "${Freexl_LIBRARY_DEBUG}"
        )
    endif()
endif()
