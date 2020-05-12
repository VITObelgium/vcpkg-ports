if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore" OR NOT VCPKG_CMAKE_SYSTEM_NAME)
    message(FATAL_ERROR "This port is only for openmpi on Unix-like systems")
endif()

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

set(OpenMPI_FULL_VERSION "4.0.3")
set(OpenMPI_SHORT_VERSION "4.0")
set(VCPKG_BUILD_TYPE "release")

vcpkg_download_distfile(ARCHIVE
    URLS "https://download.open-mpi.org/release/open-mpi/v${OpenMPI_SHORT_VERSION}/openmpi-${OpenMPI_FULL_VERSION}.tar.gz"
    FILENAME "openmpi-${OpenMPI_FULL_VERSION}.tar.gz"
    SHA512 23a9dfb7f4a63589b82f4e073a825550d3bc7e6b34770898325323ef4a28ed90b47576acaae6be427eb2007b37a88e18c1ea44d929b8ca083fe576ef1111fef6
)

vcpkg_extract_source_archive_ex(
    ARCHIVE ${ARCHIVE}
    OUT_SOURCE_PATH SOURCE_PATH
)

vcpkg_configure_autoconf(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        --bindir=${CURRENT_PACKAGES_DIR}/tools
        --disable-java
        --disable-visibility # handled by the compiler flags
    OPTIONS_DEBUG
        --enable-debug
)

file(GLOB_RECURSE OPENMPI_MAKEFILES LIST_DIRECTORIES false ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/*Makefile)
#foreach(OPENMPI_MAKEFILE IN LISTS OPENMPI_MAKEFILES)
#    vcpkg_replace_string(${OPENMPI_MAKEFILE} "${CURRENT_PACKAGES_DIR}" "${CURRENT_INSTALLED_DIR}")
#endforeach()

vcpkg_install_autotools()
vcpkg_fixup_pkgconfig_file(NAMES ompi-c ompi-cxx ompi-f90 ompi-fort ompi orte)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/openmpi RENAME copyright)
