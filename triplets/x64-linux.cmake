set(VCPKG_TARGET_ARCHITECTURE x64)
set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_LIBRARY_LINKAGE static)

set(CMAKE_C_COMPILER gcc CACHE STRING "")
set(CMAKE_ASM_COMPILER gcc CACHE STRING "")
set(CMAKE_CXX_COMPILER g++ CACHE STRING "")

set(CMAKE_POSITION_INDEPENDENT_CODE ON CACHE BOOL "")

if (NOT VCPKG_ALLOW_SYSTEM_LIBS)
    set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
    set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
endif ()