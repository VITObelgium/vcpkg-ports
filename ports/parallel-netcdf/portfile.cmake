vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO  Parallel-NetCDF/PnetCDF
    REF checkpoint.1.12.3
    SHA512 9972979c21649e4f13bf55b8c4841eb200be111ea74f7ea4fb8e76b4bedd9f423d0edded15fc36edc1e8d1b620b461aecdb4a7b33ab262b9dd974b6135c63dfc
    HEAD_REF master
)

if (UNIX)
    set(VCPKG_BUILD_TYPE release)
    set(CONFIG_OPTS "")

    TEST_FEATURE("fortran" ENABLE_FORTRAN)
    if (ENABLE_FORTRAN)
        list(APPEND CONFIG_OPTS --enable-fortran)
    else ()
        list(APPEND CONFIG_OPTS --disable-fortran)
    endif ()

    if (NOT EXISTS ${SOURCE_PATH}/configure)
        vcpkg_execute_required_process(
            COMMAND autoreconf -vfi
            WORKING_DIRECTORY ${SOURCE_PATH}
            LOGNAME prerun-${TARGET_TRIPLET}
        )
    endif ()

    set(PORT_LINKER_FLAGS -ldl -lm)

    vcpkg_configure_autoconf(
        SOURCE_PATH ${SOURCE_PATH}
        OPTIONS
            MPICC=${CURRENT_INSTALLED_DIR}/tools/openmpi/bin/mpicc
            MPICXX=${CURRENT_INSTALLED_DIR}/tools/openmpi/bin/mpicxx
            MPIF77=${CURRENT_INSTALLED_DIR}/tools/openmpi/bin/mpif77
            MPIF90=${CURRENT_INSTALLED_DIR}/tools/openmpi/bin/mpif90
            FCFLAGS=-fallow-argument-mismatch
            --with-mpi=${CURRENT_INSTALLED_DIR}
            --enable-netcdf4
            --bindir=${CURRENT_PACKAGES_DIR}/tools
            --disable-silent-rules
            ${CONFIG_OPTS}
            ac_cv_search_nc_open=-lnetcdf
    )

    vcpkg_install_autotools()
else ()
    message(FATAL_ERROR "${PORT} is only supported on unix")
endif()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYRIGHT DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
