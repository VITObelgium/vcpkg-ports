set(VCPKG_TARGET_ARCHITECTURE x64 CACHE STRING "")
set(VCPKG_CRT_LINKAGE dynamic CACHE STRING "")
set(VCPKG_LIBRARY_LINKAGE static CACHE STRING "")
set(VCPKG_PLATFORM_TOOLSET "v143" CACHE STRING "")
set(VCPKG_ENV_PASSTHROUGH "LIB;PATH;CPATH;ONEAPI_ROOT;INTEL_TARGET_ARCH;INTEL_TARGET_PLATFORM;USE_INTEL_LLVM;IFORT_COMPILER23;VARSDIR" CACHE STRING "")
set(VCPKG_POLICY_SKIP_ARCHITECTURE_CHECK enabled)
set(VCPKG_LOAD_VCVARS_ENV OFF CACHE BOOL "")
set(VCPKG_CMAKE_CONFIGURE_OPTIONS "-DVCPKG_INTEL_ONEAPI=ON")
set(VCPKG_C_FLAGS "/QaxCORE-AVX2")
set(VCPKG_CXX_FLAGS "/QaxCORE-AVX2")
set(VCPKG_Fortran_FLAGS "/QaxCORE-AVX2")
