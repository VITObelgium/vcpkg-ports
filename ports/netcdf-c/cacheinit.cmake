if (UNIX)
    set(NC_EXTRA_DEPS "-lz" CACHE STRING "Additional libraries to link against." FORCE)
    set(CMAKE_REQUIRED_LIBRARIES "-lm -ldl" CACHE STRING "Additional libraries to link against when checking for functions." FORCE)
endif ()