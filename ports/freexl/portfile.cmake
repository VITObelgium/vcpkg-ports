include(vcpkg_common_functions)
set(FREEXL_VERSION_STR "1.0.5")

vcpkg_download_distfile(ARCHIVE
    URLS "http://www.gaia-gis.it/gaia-sins/freexl-sources/freexl-${FREEXL_VERSION_STR}.tar.gz"
    FILENAME "freexl-${FREEXL_VERSION_STR}.tar.gz"
    SHA512 86d742f58353be1f3ab683899a4d914845250b481acc078c769ef337d0a6ea24d25501a3e7c73b95904c6839ddd35f53e58ad4eee0c3b433caa84db0a8c6462b
)

if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_extract_source_archive_ex(
        ARCHIVE ${ARCHIVE}
        OUT_SOURCE_PATH SOURCE_PATH
        PATCHES
            fix-makefiles.patch
            fix-sources.patch
    )
    
    set(LIBS_ALL_DBG 
      "\"${CURRENT_INSTALLED_DIR}/debug/lib/libiconvd.lib\" \
      \"${CURRENT_INSTALLED_DIR}/debug/lib/libcharsetd.lib\""
      )
    set(LIBS_ALL_REL 
      "\"${CURRENT_INSTALLED_DIR}/lib/libiconv.lib\" \
      \"${CURRENT_INSTALLED_DIR}/lib/libcharset.lib\""
      )
    
    vcpkg_install_nmake(
        SOURCE_PATH ${SOURCE_PATH}
        OPTIONS_DEBUG
            INSTALLED_ROOT="${CURRENT_INSTALLED_DIR}/debug"
            INST_DIR="${CURRENT_PACKAGES_DIR}/debug"
            "LINK_FLAGS=/debug"
            "LIBS_ALL=${LIBS_ALL_DBG}"
        OPTIONS_RELEASE
            INSTALLED_ROOT="${CURRENT_INSTALLED_DIR}"
            INST_DIR="${CURRENT_PACKAGES_DIR}"
            "LINK_FLAGS="
            "LIBS_ALL=${LIBS_ALL_REL}"
        
    )
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
    file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/freexl RENAME copyright)
    
    if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
      file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
      file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)
      file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/freexl_i.lib)
      file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/lib/freexl_i.lib)      
    else()
      file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/freexl.lib)
      file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/lib/freexl.lib)
      if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        file(RENAME ${CURRENT_PACKAGES_DIR}/lib/freexl_i.lib ${CURRENT_PACKAGES_DIR}/lib/freexl.lib)
      endif()
      if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/freexl_i.lib ${CURRENT_PACKAGES_DIR}/debug/lib/freexl.lib)
      endif()
    endif()

elseif (CMAKE_HOST_UNIX OR CMAKE_HOST_APPLE) # Build in UNIX

    vcpkg_extract_source_archive_ex(
        ARCHIVE ${ARCHIVE}
        OUT_SOURCE_PATH SOURCE_PATH
    )
    
    vcpkg_configure_make(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS_DEBUG
        INSTALLED_ROOT="${CURRENT_INSTALLED_DIR}"
        "LINK_FLAGS=/debug"
        "CL_FLAGS=${CL_FLAGS_DBG}"
        "LIBS_ALL=${LIBS_ALL_DBG}"
    OPTIONS_RELEASE
        INSTALLED_ROOT="${CURRENT_INSTALLED_DIR}"
        "LINK_FLAGS="
        "CL_FLAGS=${CL_FLAGS_REL}"
        "LIBS_ALL=${LIBS_ALL_REL}"
    )
    
    vcpkg_install_make()
    vcpkg_fixup_pkgconfig_file()

    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
      file(GLOB DYLIB_FILES ${CURRENT_PACKAGES_DIR}/lib/*.dylib)
      if (DYLIB_FILES)
        file(REMOVE ${DYLIB_FILES})
      endif ()

      file(GLOB DYLIB_FILES_DBG ${CURRENT_PACKAGES_DIR}/debug/lib/*.dylib)
      if (DYLIB_FILES_DBG)
        file(REMOVE ${DYLIB_FILES_DBG})
      endif ()

      file(GLOB SO_FILES ${CURRENT_PACKAGES_DIR}/lib/*.so*)
      if (SO_FILES)
        file(REMOVE ${SO_FILES})
      endif ()

      file(GLOB SO_FILES_DBG ${CURRENT_PACKAGES_DIR}/debug/lib/*.so*)
      if (SO_FILES_DBG)
        file(REMOVE ${SO_FILES_DBG})
      endif ()
    endif()
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
    file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/freexl RENAME copyright)

else()# Other build system
    message(FATAL_ERROR "Unsupported build system.")
endif()

message(STATUS "Packaging ${TARGET_TRIPLET} done")
file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/FindFreexl.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/cmake)
vcpkg_test_cmake(PACKAGE_NAME Freexl MODULE)