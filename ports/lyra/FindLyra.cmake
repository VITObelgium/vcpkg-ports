include(FindPackageHandleStandardArgs)

find_path(Lyra_INCLUDE_DIR
    NAMES lyra/lyra.hpp
    HINTS ${Lyra_ROOT_DIR}/include ${Lyra_INCLUDEDIR}
)

find_package_handle_standard_args(Lyra
    FOUND_VAR Lyra_FOUND
    REQUIRED_VARS Lyra_INCLUDE_DIR
)

mark_as_advanced(Lyra_ROOT_DIR Lyra_INCLUDE_DIR)

if(Lyra_FOUND AND NOT TARGET BFG::Lyra)
    add_library(BFG::Lyra INTERFACE IMPORTED)
    set_target_properties(BFG::Lyra PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${Lyra_INCLUDE_DIR}"
    )
    target_compile_features(BFG::Lyra INTERFACE cxx_std_11)
endif()
