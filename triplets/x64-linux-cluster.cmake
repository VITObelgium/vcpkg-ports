set(VCPKG_TARGET_ARCHITECTURE x64 CACHE STRING "")
set(VCPKG_CRT_LINKAGE dynamic CACHE STRING "")
set(VCPKG_LIBRARY_LINKAGE static CACHE STRING "")
set(VCPKG_CMAKE_SYSTEM_NAME Linux CACHE STRING "")

set(LINKER_EXECUTABLE ld.gold CACHE FILEPATH "")
set(VCPKG_LINKER_FLAGS "-static-libstdc++ -static-libgcc -fuse-ld=gold" CACHE STRING "" FORCE)
set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${CMAKE_CURRENT_LIST_DIR}/toolchain-linux-cluster.cmake" CACHE FILEPATH "")

# make sure the static openmp library is used
set(HOST x86_64-unknown-linux-gnu CACHE STRING "")
set(OpenMP_gomp_LIBRARY "/tools/toolchains/${HOST}/${HOST}/lib64/libgomp.a" CACHE STRING "")

