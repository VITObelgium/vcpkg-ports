# This port represents a dependency on the Meson build system.
# In the future, it is expected that this port acquires and installs Meson.
# Currently is used in ports that call vcpkg_find_acquire_program(MESON) in order to force rebuilds.

set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

set(program MESON)
set(program_version 0.64.1)
set(program_name meson)
set(search_names meson meson.py)
set(interpreter PYTHON3)
set(apt_package_name "meson")
set(brew_package_name "meson")
set(ref f341097c7e7914c250133bd58feb4985d1fbdcd6)
set(paths_to_search "${CURRENT_PACKAGES_DIR}/tools/meson")
set(download_urls "https://github.com/mesonbuild/meson/archive/${ref}.tar.gz")
set(download_filename "meson-${ref}.tar.gz")
set(download_sha512 70d3b8ac64b093c9dda4d37d1cac2b5a0b78e4c6715d261363ecc6ea06091bccc5a4918a0ac6025fc777048dc7762d9e165f1e24dbfc35e2960fb347741d5d3f)
set(supported_on_unix ON)
set(version_command --version)
set(extra_search_args EXACT_VERSION_MATCH)

vcpkg_find_acquire_program(PYTHON3)

# Reenable if no patching of meson is required within vcpkg
# z_vcpkg_find_acquire_program_find_external("${program}"
#    ${extra_search_args}
#    PROGRAM_NAME "${program_name}"
#    MIN_VERSION "${program_version}"
#    INTERPRETER "${interpreter}"
#    NAMES ${search_names}
#    VERSION_COMMAND ${version_command}
# )

if(NOT "${program}")
    vcpkg_download_distfile(archive_path
        URLS ${download_urls}
        SHA512 "${download_sha512}"
        FILENAME "${download_filename}"
    )
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools")
    vcpkg_execute_in_download_mode(
                        COMMAND "${CMAKE_COMMAND}" -E tar xzf "${archive_path}"
                        WORKING_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools"
                    )
    file(RENAME "${CURRENT_PACKAGES_DIR}/tools/meson-${ref}" "${CURRENT_PACKAGES_DIR}/tools/meson")
    z_vcpkg_apply_patches(
        SOURCE_PATH "${CURRENT_PACKAGES_DIR}"
        PATCHES
            meson-intl.patch
    )
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/tools/meson/test cases")
    configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-port-config.cmake" "${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg-port-config.cmake" @ONLY)
endif()

z_vcpkg_find_acquire_program_find_internal("${program}"
    INTERPRETER "${interpreter}"
    PATHS ${paths_to_search}
    NAMES ${search_names}
)

message(STATUS "Using meson: ${MESON}")
file(WRITE "${CURRENT_PACKAGES_DIR}/share/meson/version.txt" "${program_version}") # For vcpkg_find_acquire_program
