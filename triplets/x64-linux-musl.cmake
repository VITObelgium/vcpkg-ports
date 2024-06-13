set(VCPKG_TARGET_ARCHITECTURE x64 CACHE STRING "")
set(VCPKG_CRT_LINKAGE static CACHE STRING "")
set(VCPKG_LIBRARY_LINKAGE static CACHE STRING "")
set(VCPKG_CMAKE_SYSTEM_NAME Linux CACHE STRING "")
set(VCPKG_SYSROOT /tools/toolchains/x86_64-multilib-linux-musl/x86_64-multilib-linux-musl/sysroot CACHE FILEPATH "")

set(VCPKG_LINKER_FLAGS "-fuse-ld=gold" CACHE STRING "" FORCE)
set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${CMAKE_CURRENT_LIST_DIR}/toolchain-linux-musl.cmake" CACHE FILEPATH "")
