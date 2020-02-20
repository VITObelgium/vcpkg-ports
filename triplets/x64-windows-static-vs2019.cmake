set(VCPKG_TARGET_ARCHITECTURE x64)
set(VCPKG_CRT_LINKAGE static)
set(VCPKG_LIBRARY_LINKAGE static)
set(VCPKG_LIBRARY_LINKAGE static)
set(VCPKG_PLATFORM_TOOLSET v142)

if(VCPKG_CLANG)
    if (VCPKG_CLANG_PATH)
        file(TO_CMAKE_PATH "${VCPKG_CLANG_PATH}" _CLANG_PREFIX)
    endif()

    # requires cmake 3.15 or higher
    set(CMAKE_C_COMPILER ${_CLANG_PREFIX}/clang.exe CACHE STRING "")
    set(CMAKE_CXX_COMPILER ${_CLANG_PREFIX}/clang++.exe CACHE STRING "")
    set(CMAKE_RC_COMPILER ${_CLANG_PREFIX}/llvm-rc.exe CACHE STRING "")
    set(CMAKE_LINKER ${_CLANG_PREFIX}/lld-link.exe CACHE STRING "")
else ()
    set(CMAKE_CXX_FLAGS "/DWIN32 /D_WINDOWS /W3 /utf-8 /GR /EHsc /MP ${VCPKG_CXX_FLAGS}" CACHE STRING "")
    set(CMAKE_C_FLAGS "/DWIN32 /D_WINDOWS /W3 /utf-8 /MP ${VCPKG_C_FLAGS}" CACHE STRING "")
    set(CMAKE_RC_FLAGS "-c65001 /DWIN32" CACHE STRING "")

    set(CMAKE_CXX_FLAGS_DEBUG "/D_DEBUG /MTd /Z7 /Ob0 /Od /RTC1 /MP" CACHE STRING "")
    set(CMAKE_C_FLAGS_DEBUG "/D_DEBUG /MTd /Z7 /Ob0 /Od /RTC1 /MP" CACHE STRING "")
    set(CMAKE_CXX_FLAGS_RELEASE "/MT /O2 /Oi /Gy /DNDEBUG /Z7 /MP" CACHE STRING "")
    set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "/MT /O1 /Oi /Gy /Z7 /MP" CACHE STRING "")
    set(CMAKE_C_FLAGS_RELEASE "/MT /O2 /Oi /Gy /DNDEBUG /Z7 /MP" CACHE STRING "")
    set(CMAKE_C_FLAGS_RELWITHDEBINFO "/MT /O1 /Oi /Gy /Z7 /MP" CACHE STRING "")
    set(CMAKE_SHARED_LINKER_FLAGS_RELEASE "/DEBUG /INCREMENTAL:NO /OPT:REF /OPT:ICF" CACHE STRING "")
    set(CMAKE_MODULE_LINKER_FLAGS_RELEASE "/DEBUG /INCREMENTAL:NO /OPT:REF /OPT:ICF" CACHE STRING "")
    set(CMAKE_EXE_LINKER_FLAGS_RELEASE "/DEBUG /INCREMENTAL:NO /OPT:REF /OPT:ICF" CACHE STRING "")
endif()

set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")