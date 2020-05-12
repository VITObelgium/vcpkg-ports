vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO  Parallel-NetCDF/PnetCDF
    REF checkpoint.1.12.1
    SHA512 0
    HEAD_REF master
)

if (UNIX)
    set(VCPKG_BUILD_TYPE release)

    vcpkg_configure_autoconf(
        SOURCE_PATH ${SOURCE_PATH}
    )

    vcpkg_build_autotools()
    vcpkg_install_autotools()
    #vcpkg_fixup_pkgconfig_file(NAMES ompi-c ompi-cxx ompi-f90 ompi-fort ompi orte)
else ()
    message(FATAL_ERROR "${PORT} is only supported on unix")
endif()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYRIGHT DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
