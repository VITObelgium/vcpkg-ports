#.rst:
# .. command:: vcpkg_assemble_compiler_cflags
# .. command:: vcpkg_assemble_compiler_cxxflags
#
#  Create compiler flags based on the current cmake toolchain
#  to pass to other build systems
#
#  ::
#  vcpkg_detect_cxx_compiler(OUT_VAR_CXX_COMPILER)
#  vcpkg_assemble_compiler_cflags(OUT_VAR_DEBUG OUT_VAR_RELEASE)
#  vcpkg_assemble_compiler_cxxflags(OUT_VAR_DEBUG OUT_VAR_RELEASE)
#
function(vcpkg_detect_compilers)
    cmake_parse_arguments(_cf "" "C;CXX;Fortran;RANLIB;AR;LD" "" ${ARGN})
    
    if(NOT _VCPKG_CMAKE_VARS_FILE)
        vcpkg_internal_get_cmake_vars(OUTPUT_FILE _VCPKG_CMAKE_VARS_FILE)
        set(_VCPKG_CMAKE_VARS_FILE "${_VCPKG_CMAKE_VARS_FILE}" PARENT_SCOPE)
    endif()
    debug_message("Including cmake vars from: ${_VCPKG_CMAKE_VARS_FILE}")
    include("${_VCPKG_CMAKE_VARS_FILE}")
    set (${_cf_C} "${VCPKG_DETECTED_CMAKE_C_COMPILER}" PARENT_SCOPE)
    set (${_cf_CXX} "${VCPKG_DETECTED_CMAKE_CXX_COMPILER}" PARENT_SCOPE)
    set (${_cf_Fortran} "${VCPKG_DETECTED_CMAKE_Fortran_COMPILER}" PARENT_SCOPE)
    set (${_cf_RANLIB} "${VCPKG_DETECTED_CMAKE_RANLIB}" PARENT_SCOPE)
    set (${_cf_AR} "${VCPKG_DETECTED_CMAKE_AR}" PARENT_SCOPE)
    set (${_cf_LD} "${VCPKG_DETECTED_CMAKE_LINKER}" PARENT_SCOPE)
endfunction()

function(vcpkg_detect_compiler_flags)
    if (NOT UNIX)
        return()
    endif ()

    if(NOT _VCPKG_CMAKE_VARS_FILE)
        vcpkg_internal_get_cmake_vars(OUTPUT_FILE _VCPKG_CMAKE_VARS_FILE)
        set(_VCPKG_CMAKE_VARS_FILE "${_VCPKG_CMAKE_VARS_FILE}" PARENT_SCOPE)
    endif()
    debug_message("Including cmake vars from: ${_VCPKG_CMAKE_VARS_FILE}")
    include("${_VCPKG_CMAKE_VARS_FILE}")    

    cmake_parse_arguments(_cf "" "STANDARD;C_DEBUG;C_RELEASE;CXX_DEBUG;CXX_RELEASE;FC_DEBUG;FC_RELEASE;LD_DEBUG;LD_RELEASE" "" ${ARGN})

    # C
    set(_calc_CFLAGS)
    if (VCPKG_DETECTED_CMAKE_C_FLAGS_INIT)
        set (_calc_CFLAGS "${VCPKG_DETECTED_CMAKE_C_FLAGS_INIT}")
    endif ()

    if (VCPKG_DETECTED_CMAKE_C_FLAGS_INIT_DEBUG)
        set (_calc_CFLAGS_DEBUG "${VCPKG_DETECTED_CMAKE_C_FLAGS_INIT_DEBUG}")
    else ()
        set (_calc_CFLAGS_DEBUG "-g")
    endif ()

    if (VCPKG_DETECTED_CMAKE_C_FLAGS_INIT_RELEASE)
        set (_calc_CFLAGS_RELEASE "${VCPKG_DETECTED_CMAKE_C_FLAGS_INIT_RELEASE}")
    else ()
        set (_calc_CFLAGS_RELEASE "-O3 -DNDEBUG")
    endif ()

    if (VCPKG_DETECTED_CMAKE_C_VISIBILITY_PRESET)
        set(_calc_CFLAGS "${_calc_CFLAGS} -fvisibility=${VCPKG_DETECTED_CMAKE_C_VISIBILITY_PRESET}")
    endif ()

    if (VCPKG_DETECTED_CMAKE_POSITION_INDEPENDENT_CODE)
        set(_calc_CFLAGS "${_calc_CFLAGS} -fPIC")
    endif ()

    if (VCPKG_DETECTED_CMAKE_SYSROOT)
        set(_calc_CFLAGS "${_calc_CFLAGS} --sysroot=${VCPKG_DETECTED_CMAKE_SYSROOT}")
    endif ()

    # Seems to be already present in the C FLAGS
    # if (VCPKG_DETECTED_CMAKE_OSX_SYSROOT)
    #     set(_calc_CFLAGS "${_calc_CFLAGS} -isysroot ${VCPKG_DETECTED_CMAKE_OSX_SYSROOT}")
    # endif ()

    if (VCPKG_DETECTED_CMAKE_OSX_DEPLOYMENT_TARGET)
        set(_calc_CFLAGS "${_calc_CFLAGS} -mmacosx-version-min=${VCPKG_DETECTED_CMAKE_OSX_DEPLOYMENT_TARGET}")
    endif ()

    set (${_cf_C_DEBUG} "${_calc_CFLAGS} ${_calc_CFLAGS_DEBUG} ${VCPKG_DETECTED_CMAKE_C_FLAGS} ${VCPKG_DETECTED_CMAKE_C_FLAGS_DEBUG}" PARENT_SCOPE)
    set (${_cf_C_RELEASE} "${_calc_CFLAGS} ${_calc_CFLAGS_RELEASE} ${VCPKG_DETECTED_CMAKE_C_FLAGS} ${VCPKG_DETECTED_CMAKE_C_FLAGS_RELEASE}" PARENT_SCOPE)

    # CXX
    set(_calc_CXXFLAGS)
    if (VCPKG_DETECTED_CMAKE_CXX_FLAGS_INIT)
        set (_calc_CXXFLAGS "${VCPKG_DETECTED_CMAKE_CXX_FLAGS_INIT}")
    elseif (_cf_STANDARD)
        set (_calc_CXXFLAGS "-std=c++${_cf_STANDARD}")
    else ()
        set (_calc_CXXFLAGS "-std=c++17")
    endif ()

    if (VCPKG_DETECTED_CMAKE_CXX_FLAGS_INIT_DEBUG)
        set (_calc_CXXFLAGS_DEBUG "${VCPKG_DETECTED_CMAKE_CXX_FLAGS_INIT_DEBUG}")
    else ()
        set (_calc_CXXFLAGS_DEBUG "-g")
    endif ()

    if (VCPKG_DETECTED_CMAKE_CXX_FLAGS_INIT_RELEASE)
        set (_calc_CXXFLAGS_RELEASE "${VCPKG_DETECTED_CMAKE_CXX_FLAGS_INIT_RELEASE}")
    else ()
        set (_calc_CXXFLAGS_RELEASE "-O3 -DNDEBUG")
    endif ()

    if (VCPKG_DETECTED_CMAKE_CXX_VISIBILITY_PRESET)
        set(_calc_CXXFLAGS "${_calc_CXXFLAGS} -fvisibility=${VCPKG_DETECTED_CMAKE_CXX_VISIBILITY_PRESET}")
    endif ()

    if (VCPKG_DETECTED_CMAKE_VISIBILITY_INLINES_HIDDEN)
        set(_calc_CXXFLAGS "${_calc_CXXFLAGS} -fvisibility-inlines-hidden")
    endif ()

    if (VCPKG_DETECTED_CMAKE_POSITION_INDEPENDENT_CODE)
        set(_calc_CXXFLAGS "${_calc_CXXFLAGS} -fPIC")
    endif ()

    if (VCPKG_DETECTED_CMAKE_SYSROOT)
        set(_calc_CXXFLAGS "${_calc_CXXFLAGS} --sysroot=${VCPKG_DETECTED_CMAKE_SYSROOT}")
    endif ()

    # Seems to be already present in the CXX FLAGS
    # if (VCPKG_DETECTED_CMAKE_OSX_SYSROOT)
    #     set(_calc_CXXFLAGS "${_calc_CXXFLAGS} -isysroot ${VCPKG_DETECTED_CMAKE_OSX_SYSROOT}")
    # endif ()

    if (VCPKG_DETECTED_CMAKE_OSX_DEPLOYMENT_TARGET)
        set(_calc_CXXFLAGS "${_calc_CXXFLAGS} -mmacosx-version-min=${VCPKG_DETECTED_CMAKE_OSX_DEPLOYMENT_TARGET}")
    endif ()

    set (${_cf_CXX_DEBUG} "${_calc_CXXFLAGS} ${_calc_CXXFLAGS_DEBUG} ${VCPKG_DETECTED_CMAKE_CXX_FLAGS} ${VCPKG_DETECTED_CMAKE_CXX_FLAGS_DEBUG}" PARENT_SCOPE)
    set (${_cf_CXX_RELEASE} "${_calc_CXXFLAGS} ${_calc_CXXFLAGS_RELEASE} ${VCPKG_DETECTED_CMAKE_CXX_FLAGS} ${VCPKG_DETECTED_CMAKE_CXX_FLAGS_RELEASE}" PARENT_SCOPE)

    # Fortran
    set(_calc_FCFLAGS)
    if (VCPKG_DETECTED_CMAKE_Fortran_FLAGS_INIT)
        set (_calc_FCFLAGS "${VCPKG_DETECTED_CMAKE_Fortran_FLAGS_INIT}")
    endif ()

    if (VCPKG_DETECTED_CMAKE_Fortran_FLAGS_INIT_DEBUG)
        set (_calc_FCFLAGS_DEBUG "${VCPKG_DETECTED_CMAKE_Fortran_FLAGS_INIT_DEBUG}")
    else ()
        set (_calc_FCFLAGS_DEBUG "-g")
    endif ()

    if (VCPKG_DETECTED_CMAKE_Fortran_FLAGS_INIT_RELEASE)
        set (_calc_FCFLAGS_RELEASE "${VCPKG_DETECTED_CMAKE_Fortran_FLAGS_INIT_RELEASE}")
    else ()
        set (_calc_FCFLAGS_RELEASE "-O3 -DNDEBUG")
    endif ()

    set (${_cf_FC_DEBUG} "${_calc_FCFLAGS} ${_calc_FCFLAGS_DEBUG} ${VCPKG_DETECTED_CMAKE_Fortran_FLAGS} ${VCPKG_DETECTED_CMAKE_Fortran_FLAGS_DEBUG}" PARENT_SCOPE)
    set (${_cf_FC_RELEASE} "${_calc_FCFLAGS} ${_calc_FCFLAGS_RELEASE} ${VCPKG_DETECTED_CMAKE_Fortran_FLAGS} ${VCPKG_DETECTED_CMAKE_Fortran_FLAGS_RELEASE}" PARENT_SCOPE)

    # linker
    set(_calc_LDFLAGS)
    set(_calc_LDFLAGS_DEBUG)
    set(_calc_LDFLAGS_RELEASE)
    set (${_cf_LD_DEBUG} "${_calc_LDFLAGS} ${_calc_LDFLAGS_DEBUG} ${VCPKG_DETECTED_CMAKE_EXE_LINKER_FLAGS} ${VCPKG_DETECTED_CMAKE_EXE_LINKER_FLAGS_DEBUG}" PARENT_SCOPE)
    set (${_cf_LD_RELEASE} "${_calc_LDFLAGS} ${_calc_LDFLAGS_RELEASE} ${VCPKG_DETECTED_CMAKE_EXE_LINKER_FLAGS} ${VCPKG_DETECTED_CMAKE_EXE_LINKER_FLAGS_RELEASE}" PARENT_SCOPE)
endfunction()

