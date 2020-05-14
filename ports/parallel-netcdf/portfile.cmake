vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO  Parallel-NetCDF/PnetCDF
    REF checkpoint.1.12.1
    SHA512 54b12f8a59af547124fb7b92e47f556e53e9dfe3cb738c13181ae86842325e2bc633c22ecc28c214179d7f5a7b9103717d8b0e9a490d24584c9c873088ec3ca3
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
            MPICC=${CURRENT_INSTALLED_DIR}/tools/mpicc
            MPICXX=${CURRENT_INSTALLED_DIR}/tools/mpicxx
            MPIF77=${CURRENT_INSTALLED_DIR}/tools/mpif77
            MPIF90=${CURRENT_INSTALLED_DIR}/tools/mpif90
            --with-mpi=${CURRENT_INSTALLED_DIR}
            --enable-netcdf4
            --bindir=${CURRENT_PACKAGES_DIR}/tools
            --disable-silent-rules
            ${CONFIG_OPTS}
    )

    vcpkg_install_autotools()
else ()
    message(FATAL_ERROR "${PORT} is only supported on unix")
endif()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYRIGHT DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
