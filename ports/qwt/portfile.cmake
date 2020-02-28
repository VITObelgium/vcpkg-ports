if (VCPKG_TARGET_IS_OSX)
    set(VCPKG_BUILD_TYPE release)
endif ()

vcpkg_download_distfile(ARCHIVE
    URLS "https://sourceforge.net/projects/qwt/files/qwt/6.1.4/qwt-6.1.4.zip"
    FILENAME "qwt-6.1.4.zip"
    SHA512 711256ec4d1d54d201650e9c63b584b17a61dbedde5a581e0b6227fdbee149cdbe2a889aa58f67777125b6471fc1fe248992ec845eb6481a2dfc2c4276701d7f
)

vcpkg_extract_source_archive_ex(
    ARCHIVE ${ARCHIVE}
    OUT_SOURCE_PATH SOURCE_PATH
    PATCHES fix-dynamic-static.patch
)

set(DEBUG_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")
set(RELEASE_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")

vcpkg_configure_qmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        CONFIG+=${VCPKG_LIBRARY_LINKAGE}
)

if (CMAKE_HOST_WIN32)
    vcpkg_build_qmake(
        RELEASE_TARGETS sub-src-release_ordered
        DEBUG_TARGETS sub-src-debug_ordered
    )
elseif (CMAKE_HOST_UNIX OR CMAKE_HOST_APPLE) # Build in UNIX
    vcpkg_build_qmake(
        RELEASE_TARGETS sub-src-all-ordered
        DEBUG_TARGETS sub-src-all-ordered
    )
endif()

#Set the correct install directory to packages
foreach(MAKEFILE ${RELEASE_MAKEFILES} ${DEBUG_MAKEFILES})
    vcpkg_replace_string(${MAKEFILE} "(INSTALL_ROOT)${INSTALLED_DIR_WITHOUT_DRIVE}" "(INSTALL_ROOT)${PACKAGES_DIR_WITHOUT_DRIVE}")
endforeach()

#Install the header files
file(GLOB HEADER_FILES ${SOURCE_PATH}/src/*.h)
file(INSTALL ${HEADER_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include/qwt)

#Install the module files
if (CMAKE_HOST_WIN32)
    file(INSTALL ${RELEASE_DIR}/lib/qwt.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
    file(INSTALL ${DEBUG_DIR}/lib/qwtd.lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)

    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        file(INSTALL ${RELEASE_DIR}/lib/qwt.dll DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
        file(INSTALL ${DEBUG_DIR}/lib/qwtd.dll DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
    endif()
    vcpkg_copy_pdbs()
elseif (CMAKE_HOST_UNIX OR CMAKE_HOST_APPLE) # Build in UNIX
    file(INSTALL ${RELEASE_DIR}/lib/libqwt.a DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
    if (NOT VCPKG_TARGET_IS_OSX)
        file(INSTALL ${DEBUG_DIR}/lib/libqwt.a DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
    endif ()
endif()


# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/qwt)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/qwt/COPYING ${CURRENT_PACKAGES_DIR}/share/qwt/copyright)