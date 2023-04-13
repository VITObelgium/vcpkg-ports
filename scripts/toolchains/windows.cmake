if(NOT _VCPKG_WINDOWS_TOOLCHAIN)
    set(_VCPKG_WINDOWS_TOOLCHAIN 1)
    set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>$<$<STREQUAL:${VCPKG_CRT_LINKAGE},dynamic>:DLL>" CACHE STRING "")

    set(CMAKE_SYSTEM_NAME Windows CACHE STRING "")

    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
        set(CMAKE_SYSTEM_PROCESSOR x86 CACHE STRING "")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        set(CMAKE_SYSTEM_PROCESSOR AMD64 CACHE STRING "")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
        set(CMAKE_SYSTEM_PROCESSOR ARM CACHE STRING "")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        set(CMAKE_SYSTEM_PROCESSOR ARM64 CACHE STRING "")
    endif()

    if(DEFINED VCPKG_CMAKE_SYSTEM_VERSION)
        set(CMAKE_SYSTEM_VERSION "${VCPKG_CMAKE_SYSTEM_VERSION}" CACHE STRING "" FORCE)
    endif()

    if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows")
        if(CMAKE_SYSTEM_PROCESSOR STREQUAL CMAKE_HOST_SYSTEM_PROCESSOR)
            set(CMAKE_CROSSCOMPILING OFF CACHE STRING "")
        elseif(CMAKE_SYSTEM_PROCESSOR STREQUAL "x86")
            # any of the four platforms can run x86 binaries
            set(CMAKE_CROSSCOMPILING OFF CACHE STRING "")
        elseif(CMAKE_HOST_SYSTEM_PROCESSOR STREQUAL "ARM64")
            # arm64 can run binaries of any of the four platforms after Windows 11
            set(CMAKE_CROSSCOMPILING OFF CACHE STRING "")
        endif()

        if(NOT DEFINED CMAKE_SYSTEM_VERSION)
            set(CMAKE_SYSTEM_VERSION "${CMAKE_HOST_SYSTEM_VERSION}" CACHE STRING "")
        endif()
    endif()

    get_property(_CMAKE_IN_TRY_COMPILE GLOBAL PROPERTY IN_TRY_COMPILE)

    if(NOT _CMAKE_IN_TRY_COMPILE)
        if(VCPKG_CLANG)
            message(STATUS "### CLANG")

            if(VCPKG_CLANG_PATH)
                file(TO_CMAKE_PATH "${VCPKG_CLANG_PATH}/" _CLANG_PREFIX)
            endif()

            # requires cmake 3.15 or higher
            set(CMAKE_C_COMPILER ${_CLANG_PREFIX}clang.exe CACHE STRING "")
            set(CMAKE_CXX_COMPILER ${_CLANG_PREFIX}clang++.exe CACHE STRING "")
            set(CMAKE_RC_COMPILER ${_CLANG_PREFIX}llvm-rc.exe CACHE STRING "")
            set(CMAKE_LINKER ${_CLANG_PREFIX}lld-link.exe CACHE STRING "")
        else()
            set(MP_FLAG "/MP")

            if(VCPKG_INTEL_ONEAPI)
                message(STATUS "### INTEL ONEAPI")

                if(INTEL_ONEAPI_PATH)
                    file(TO_CMAKE_PATH "${INTEL_ONEAPI_PATH}/" _INTEL_PREFIX)
                endif()

                set(CMAKE_C_COMPILER ${_INTEL_PREFIX}icx-cl.exe CACHE STRING "")
                set(CMAKE_CXX_COMPILER ${_INTEL_PREFIX}icx-cl.exe CACHE STRING "")
                set(CMAKE_Fortran_COMPILER ${_INTEL_PREFIX}ifx.exe CACHE STRING "")
                set(MP_FLAG)
            endif()

            if(VCPKG_CRT_LINKAGE STREQUAL "dynamic")
                set(VCPKG_CRT_LINK_FLAG_PREFIX "/MD")
            elseif(VCPKG_CRT_LINKAGE STREQUAL "static")
                set(VCPKG_CRT_LINK_FLAG_PREFIX "/MT")
            else()
                message(FATAL_ERROR "Invalid setting for VCPKG_CRT_LINKAGE: \"${VCPKG_CRT_LINKAGE}\". It must be \"static\" or \"dynamic\"")
            endif()

            set(CHARSET_FLAG "/utf-8")

            if(NOT VCPKG_SET_CHARSET_FLAG OR VCPKG_PLATFORM_TOOLSET MATCHES "v120" OR VCPKG_INTEL_ONEAPI)
                # VS 2013 does not support /utf-8
                set(CHARSET_FLAG)
            endif()

            set(CMAKE_CXX_FLAGS "/nologo /DWIN32 /D_WINDOWS /W3 /fp:precise ${CHARSET_FLAG} /GR /EHsc ${MP_FLAG} ${VCPKG_CXX_FLAGS}" CACHE STRING "")
            set(CMAKE_C_FLAGS "/nologo /DWIN32 /D_WINDOWS /W3 /fp:precise ${CHARSET_FLAG} ${MP_FLAG} ${VCPKG_C_FLAGS}" CACHE STRING "")
            set(CMAKE_Fortran_FLAGS "/nologo /fp:precise ${VCPKG_Fortran_FLAGS}" CACHE STRING "")
            set(CMAKE_RC_FLAGS "-c65001 /DWIN32" CACHE STRING "")

            unset(CHARSET_FLAG)
            unset(MP_FLAG)

            set(CMAKE_CXX_FLAGS_DEBUG "/D_DEBUG ${VCPKG_CRT_LINK_FLAG_PREFIX}d /Z7 /Ob0 /Od /RTC1 ${VCPKG_CXX_FLAGS_DEBUG}" CACHE STRING "")
            set(CMAKE_C_FLAGS_DEBUG "/D_DEBUG ${VCPKG_CRT_LINK_FLAG_PREFIX}d /Z7 /Ob0 /Od /RTC1 ${VCPKG_C_FLAGS_DEBUG}" CACHE STRING "")
            set(CMAKE_CXX_FLAGS_RELEASE "${VCPKG_CRT_LINK_FLAG_PREFIX} /O2 /Oi /Gy /DNDEBUG /Z7 ${VCPKG_CXX_FLAGS_RELEASE}" CACHE STRING "")
            set(CMAKE_C_FLAGS_RELEASE "${VCPKG_CRT_LINK_FLAG_PREFIX} /O2 /Oi /Gy /DNDEBUG /Z7 ${VCPKG_C_FLAGS_RELEASE}" CACHE STRING "")

            set(CMAKE_Fortran_FLAGS_DEBUG "/Od ${VCPKG_CRT_LINK_FLAG_PREFIX}d" CACHE STRING "")
            set(CMAKE_Fortran_FLAGS_RELEASE "/O3 ${VCPKG_CRT_LINK_FLAG_PREFIX} /nodebug" CACHE STRING "")

            string(APPEND CMAKE_STATIC_LINKER_FLAGS_RELEASE_INIT " /nologo ")

            if(VCPKG_INTEL_ONEAPI)
                set(CMAKE_SHARED_LINKER_FLAGS_RELEASE "/nologo /DEBUG /INCREMENTAL:NO ${VCPKG_LINKER_FLAGS} ${VCPKG_LINKER_FLAGS_RELEASE}" CACHE STRING "")
                set(CMAKE_EXE_LINKER_FLAGS_RELEASE "/nologo /DEBUG /INCREMENTAL:NO ${VCPKG_LINKER_FLAGS} ${VCPKG_LINKER_FLAGS_RELEASE}" CACHE STRING "")
            else()
                set(CMAKE_SHARED_LINKER_FLAGS_RELEASE "/nologo /DEBUG /INCREMENTAL:NO /OPT:REF /OPT:ICF ${VCPKG_LINKER_FLAGS} ${VCPKG_LINKER_FLAGS_RELEASE}" CACHE STRING "")
                set(CMAKE_EXE_LINKER_FLAGS_RELEASE "/nologo /DEBUG /INCREMENTAL:NO /OPT:REF /OPT:ICF ${VCPKG_LINKER_FLAGS} ${VCPKG_LINKER_FLAGS_RELEASE}" CACHE STRING "")
            endif()

            string(APPEND CMAKE_STATIC_LINKER_FLAGS_DEBUG_INIT " /nologo ")
            string(APPEND CMAKE_SHARED_LINKER_FLAGS_DEBUG_INIT " /nologo ${VCPKG_LINKER_FLAGS} ${VCPKG_LINKER_FLAGS_DEBUG} ")
            string(APPEND CMAKE_EXE_LINKER_FLAGS_DEBUG_INIT " /nologo ${VCPKG_LINKER_FLAGS} ${VCPKG_LINKER_FLAGS_DEBUG} ")
        endif()
    endif()
endif()
