set(VCPKG_TARGET_ARCHITECTURE x64)
set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_LIBRARY_LINKAGE static)
set(VCPKG_CMAKE_SYSTEM_NAME Darwin)
set(VCPKG_C_VISIBILITY_PRESET hidden CACHE STRING "")
set(VCPKG_CXX_VISIBILITY_PRESET hidden CACHE STRING "")
set(VCPKG_VISIBILITY_INLINES_HIDDEN ON CACHE BOOL "")

set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${CMAKE_CURRENT_LIST_DIR}/toolchain-osx-gcc-11.cmake")

