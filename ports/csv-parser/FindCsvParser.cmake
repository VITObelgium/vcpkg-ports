include(FindPackageHandleStandardArgs)

find_path(CsvParser_INCLUDE_DIR
    NAMES csv.hpp
    HINTS ${CsvParser_ROOT_DIR}/include ${CsvParser_INCLUDEDIR}
)

find_package_handle_standard_args(CsvParser
    FOUND_VAR CsvParser_FOUND
    REQUIRED_VARS CsvParser_INCLUDE_DIR
)

mark_as_advanced(CsvParser_ROOT_DIR CsvParser_INCLUDE_DIR)

if(CsvParser_FOUND AND NOT TARGET CsvParser::csv)
    add_library(CsvParser::csv INTERFACE IMPORTED)
    set_target_properties(CsvParser::csv PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${CsvParser_INCLUDE_DIR}"
    )
endif()
