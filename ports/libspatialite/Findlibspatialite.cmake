include(FindPackageHandleStandardArgs)

find_path(libspatialite_INCLUDE_DIR
    NAMES spatialite.h
    HINTS ${libspatialite_ROOT_DIR}/include ${libspatialite_INCLUDEDIR}
)

find_package(sqlite3 CONFIG REQUIRED QUIET)
find_package(Freexl REQUIRED QUIET)
find_package(LibXml2 REQUIRED QUIET)
find_package(unofficial-iconv CONFIG REQUIRED QUIET)
find_library(libspatialite_LIBRARY NAMES spatialite HINTS ${libspatialite_ROOT_DIR}/lib)
find_library(libspatialite_LIBRARY_DEBUG NAMES spatialited spatialite HINTS ${libspatialite_ROOT_DIR}/lib)

find_package_handle_standard_args(libspatialite
    FOUND_VAR libspatialite_FOUND
    REQUIRED_VARS libspatialite_INCLUDE_DIR libspatialite_LIBRARY
)

mark_as_advanced(
    libspatialite_ROOT_DIR
    libspatialite_INCLUDE_DIR
    libspatialite_LIBRARY
    libspatialite_LIBRARY_DEBUG
)

if(libspatialite_FOUND AND NOT TARGET libspatialite::spatialite)
    add_library(libspatialite::spatialite STATIC IMPORTED)
    set_target_properties(libspatialite::spatialite PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${libspatialite_INCLUDE_DIR}"
        INTERFACE_LINK_LIBRARIES "sqlite3;freexl::freexl;LibXml2::LibXml2;unofficial::iconv::libcharset"
        IMPORTED_LOCATION ${libspatialite_LIBRARY}
    )

    if(libspatialite_LIBRARY_DEBUG)
        set_target_properties(libspatialite::spatialite PROPERTIES
            IMPORTED_LOCATION_DEBUG "${libspatialite_LIBRARY_DEBUG}"
        )
    endif()
endif()
