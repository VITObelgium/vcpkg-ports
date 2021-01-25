set(VCPKG_TARGET_ARCHITECTURE x64)
set(VCPKG_CRT_LINKAGE static)
set(VCPKG_LIBRARY_LINKAGE static)

set(VCPKG_CMAKE_SYSTEM_NAME Darwin)
set(CMAKE_OSX_DEPLOYMENT_TARGET 11.1 CACHE STRING "")
set(CMAKE_OSX_ARCHITECTURES "arm64" CACHE STRING "")

set(LLVM_ROOT /Library/Developer/CommandLineTools/usr)
set(CMAKE_C_COMPILER ${LLVM_ROOT}/bin/clang CACHE STRING "")
set(CMAKE_ASM_COMPILER ${LLVM_ROOT}/bin/clang CACHE STRING "")
set(CMAKE_CXX_COMPILER ${LLVM_ROOT}/bin/clang++ CACHE STRING "")
set(CMAKE_Fortran_COMPILER gfortran-10 CACHE STRING "")

set(CMAKE_C_VISIBILITY_PRESET hidden)
set(CMAKE_CXX_VISIBILITY_PRESET hidden)
set(CMAKE_VISIBILITY_INLINES_HIDDEN 1)

set(CMAKE_FIND_ROOT_PATH "/System/Library/Frameworks" CACHE STRING "")
if (NOT VCPKG_ALLOW_SYSTEM_LIBS)
    set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
    set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
endif ()
