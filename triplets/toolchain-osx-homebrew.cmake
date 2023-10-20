if(NOT _VCPKG_OSX_TOOLCHAIN)
    set(_VCPKG_OSX_TOOLCHAIN 1)

    set(CMAKE_SYSTEM_NAME Darwin CACHE STRING "")

    set(CMAKE_MACOSX_RPATH ON CACHE BOOL "")

    set(LLVM_ROOT_DIR /opt/homebrew/opt/llvm)
    set(CMAKE_C_COMPILER "${LLVM_ROOT_DIR}/bin/clang")
    set(CMAKE_ASM_COMPILER "${LLVM_ROOT_DIR}/bin/clang")
    set(CMAKE_CXX_COMPILER "${LLVM_ROOT_DIR}/bin/clang++")
    set(CMAKE_OSX_DEPLOYMENT_TARGET 14.0)

    set(CMAKE_C_VISIBILITY_PRESET hidden)
    set(CMAKE_CXX_VISIBILITY_PRESET hidden)
    set(CMAKE_VISIBILITY_INLINES_HIDDEN 1)

    set(OpenMP_C "${CMAKE_C_COMPILER}")
    set(OpenMP_C_FLAGS "-fopenmp=libomp -Wno-unused-command-line-argument" CACHE STRING "")
    set(OpenMP_C_LIB_NAMES "omp" "gomp" "iomp5" CACHE STRING "")
    set(OpenMP_CXX "${CMAKE_CXX_COMPILER}" CACHE STRING "")
    set(OpenMP_CXX_FLAGS "-fopenmp=libomp -Wno-unused-command-line-argument" CACHE STRING "")
    set(OpenMP_CXX_LIB_NAMES "omp" CACHE STRING "")
    set(OpenMP_omp_LIBRARY "${LLVM_ROOT_DIR}/lib/libomp.dylib" CACHE STRING "")

    set(CMAKE_FIND_ROOT_PATH "${LLVM_ROOT_DIR}" CACHE STRING "")

    if(NOT VCPKG_ALLOW_SYSTEM_LIBS)
        set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
        set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
    endif()

    if(NOT DEFINED CMAKE_SYSTEM_PROCESSOR)
        if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
            set(CMAKE_SYSTEM_PROCESSOR x86_64 CACHE STRING "")
        elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
            set(CMAKE_SYSTEM_PROCESSOR x86 CACHE STRING "")
        elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
            set(CMAKE_SYSTEM_PROCESSOR arm64 CACHE STRING "")
        else()
            set(CMAKE_SYSTEM_PROCESSOR "${CMAKE_HOST_SYSTEM_PROCESSOR}" CACHE STRING "")
        endif()
    endif()

    if(DEFINED VCPKG_CMAKE_SYSTEM_VERSION)
        set(CMAKE_SYSTEM_VERSION "${VCPKG_CMAKE_SYSTEM_VERSION}" CACHE STRING "" FORCE)
    endif()

    if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Darwin")
        if(CMAKE_SYSTEM_PROCESSOR STREQUAL CMAKE_HOST_SYSTEM_PROCESSOR)
            set(CMAKE_CROSSCOMPILING OFF CACHE STRING "")
        elseif(CMAKE_HOST_SYSTEM_PROCESSOR STREQUAL "ARM64")
            # arm64 macOS can run x64 binaries
            set(CMAKE_CROSSCOMPILING OFF CACHE STRING "")
        endif()

        if(NOT DEFINED CMAKE_SYSTEM_VERSION)
            set(CMAKE_SYSTEM_VERSION "${CMAKE_HOST_SYSTEM_VERSION}" CACHE STRING "")
        endif()
    endif()

    get_property(_CMAKE_IN_TRY_COMPILE GLOBAL PROPERTY IN_TRY_COMPILE)

    if(NOT _CMAKE_IN_TRY_COMPILE)
        string(APPEND CMAKE_C_FLAGS_INIT " -fPIC ${VCPKG_C_FLAGS} ")
        string(APPEND CMAKE_CXX_FLAGS_INIT " -fPIC ${VCPKG_CXX_FLAGS} ")
        string(APPEND CMAKE_C_FLAGS_DEBUG_INIT " ${VCPKG_C_FLAGS_DEBUG} ")
        string(APPEND CMAKE_CXX_FLAGS_DEBUG_INIT " ${VCPKG_CXX_FLAGS_DEBUG} ")
        string(APPEND CMAKE_C_FLAGS_RELEASE_INIT " ${VCPKG_C_FLAGS_RELEASE} ")
        string(APPEND CMAKE_CXX_FLAGS_RELEASE_INIT " ${VCPKG_CXX_FLAGS_RELEASE} ")

        string(APPEND CMAKE_SHARED_LINKER_FLAGS_INIT " ${VCPKG_LINKER_FLAGS} ")
        string(APPEND CMAKE_EXE_LINKER_FLAGS_INIT " ${VCPKG_LINKER_FLAGS} ")
        string(APPEND CMAKE_SHARED_LINKER_FLAGS_DEBUG_INIT " ${VCPKG_LINKER_FLAGS_DEBUG} ")
        string(APPEND CMAKE_EXE_LINKER_FLAGS_DEBUG_INIT " ${VCPKG_LINKER_FLAGS_DEBUG} ")
        string(APPEND CMAKE_SHARED_LINKER_FLAGS_RELEASE_INIT " ${VCPKG_LINKER_FLAGS_RELEASE} ")
        string(APPEND CMAKE_EXE_LINKER_FLAGS_RELEASE_INIT " ${VCPKG_LINKER_FLAGS_RELEASE} ")
    endif()
endif()