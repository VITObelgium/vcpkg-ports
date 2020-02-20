# FindTypeSafe
# --------
#
# Find the Typesafe strong typing Library includes.
#
# Imported Targets
# ^^^^^^^^^^^^^^^^
#
# If Typesafe is found, this module defines the following :prop_tgt:`IMPORTED`
# targets::
#
#  Typesafe::Typesafe      - The main Typesafe library.
#
# Result Variables
# ^^^^^^^^^^^^^^^^
#
# This module will set the following variables in your project::
#
#  Typesafe_FOUND          - True if Typesafe found on the local system
#
# Hints
# ^^^^^
#
# Set ``Typesafe_ROOT_DIR`` to a directory that contains a Typesafe installation.
#
# This script expects to find the Typesafe headers at ``$Typesafe_ROOT_DIR/include/type_safe``.

include(FindPackageHandleStandardArgs)

find_path(Typesafe_INCLUDE_DIR
    NAMES type_safe/types.hpp
    HINTS ${Typesafe_ROOT_DIR}/include ${Typesafe_INCLUDEDIR}
)

find_package_handle_standard_args(Typesafe
    FOUND_VAR Typesafe_FOUND
    REQUIRED_VARS Typesafe_INCLUDE_DIR
)

mark_as_advanced(Typesafe_ROOT_DIR Typesafe_INCLUDE_DIR)

if(Typesafe_FOUND AND NOT TARGET Typesafe::Typesafe)
    add_library(Typesafe::Typesafe INTERFACE IMPORTED)
    set_target_properties(Typesafe::Typesafe PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${Typesafe_INCLUDE_DIR}"
    )
endif()
