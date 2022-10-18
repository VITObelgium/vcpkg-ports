set(VCPKG_TARGET_ARCHITECTURE arm64 CACHE STRING "")
set(VCPKG_CRT_LINKAGE static CACHE STRING "")
set(VCPKG_LIBRARY_LINKAGE static CACHE STRING "")

set(VCPKG_CMAKE_SYSTEM_NAME Darwin CACHE STRING "")
set(VCPKG_OSX_ARCHITECTURES arm64 CACHE STRING "")
set(VCPKG_OSX_DEPLOYMENT_TARGET 11.3 CACHE STRING "")
set(VCPKG_C_FLAGS "-fvisibility=hidden" CACHE STRING "")
set(VCPKG_CXX_FLAGS "-fvisibility=hidden -fvisibility-inlines-hidden" CACHE STRING "")

set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${CMAKE_CURRENT_LIST_DIR}/toolchain-osx-appleclang.cmake")

