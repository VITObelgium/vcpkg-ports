include(FindPackageHandleStandardArgs)

find_path(Zstr_INCLUDE_DIR
    NAMES zstr/zstr.hpp
    HINTS ${Zstr_ROOT_DIR}/include ${Zstr_INCLUDEDIR}
)

find_package_handle_standard_args(Zstr
    FOUND_VAR Zstr_FOUND
    REQUIRED_VARS Zstr_INCLUDE_DIR
)

find_package(ZLIB REQUIRED QUIET)

mark_as_advanced(Zstr_ROOT_DIR Zstr_INCLUDE_DIR)

if(Zstr_FOUND AND NOT TARGET zstr::zstr)
    add_library(zstr::zstr INTERFACE IMPORTED)
    set_target_properties(zstr::zstr PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${Zstr_INCLUDE_DIR}"
    )
    set_property(TARGET zstr::zstr APPEND PROPERTY INTERFACE_LINK_LIBRARIES ZLIB::ZLIB)
endif()
