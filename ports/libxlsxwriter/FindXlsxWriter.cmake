include(FindPackageHandleStandardArgs)
include(CMakeFindDependencyMacro)

find_path(XlsxWriter_INCLUDE_DIR
    NAMES xlsxwriter.h
    HINTS ${XlsxWriter_ROOT_DIR}/include ${XlsxWriter_INCLUDEDIR}
)

find_library(XlsxWriter_LIBRARY NAMES xlsxwriter HINTS ${XlsxWriter_ROOT_DIR}/lib)
find_library(XlsxWriter_LIBRARY_DEBUG NAMES xlsxwriterd HINTS ${XlsxWriter_ROOT_DIR}/debug/lib)
find_dependency(MINIZIP NAMES unofficial-minizip CONFIG REQUIRED)

message(STATUS "XlsxWriter library: ${XlsxWriter_LIBRARY}")

find_package_handle_standard_args(XlsxWriter
    FOUND_VAR XlsxWriter_FOUND
    REQUIRED_VARS XlsxWriter_INCLUDE_DIR XlsxWriter_LIBRARY
)

mark_as_advanced(
    XlsxWriter_ROOT_DIR
    XlsxWriter_INCLUDE_DIR
    XlsxWriter_LIBRARY
    XlsxWriter_LIBRARY_DEBUG
)

if(XlsxWriter_FOUND AND NOT TARGET XlsxWriter::XlsxWriter)
    add_library(XlsxWriter::XlsxWriter STATIC IMPORTED)
    set_target_properties(XlsxWriter::XlsxWriter PROPERTIES
        IMPORTED_LINK_INTERFACE_LANGUAGES "C"
        INTERFACE_INCLUDE_DIRECTORIES "${XlsxWriter_INCLUDE_DIR}"
        IMPORTED_LOCATION ${XlsxWriter_LIBRARY}
        INTERFACE_LINK_LIBRARIES "unofficial::minizip::minizip"
    )

    if(XlsxWriter_LIBRARY_DEBUG)
        set_target_properties(XlsxWriter::XlsxWriter PROPERTIES
            IMPORTED_LOCATION_DEBUG "${XlsxWriter_LIBRARY_DEBUG}"
        )
    endif()
endif()
