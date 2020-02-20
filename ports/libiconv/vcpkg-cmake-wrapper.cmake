if(NOT TARGET Iconv::Iconv)
    find_package(unofficial-iconv CONFIG QUIET ${REQUIRED})
    if (TARGET unofficial::iconv::libiconv)
        add_library(Iconv::Iconv INTERFACE IMPORTED)
        set_target_properties(Iconv::Iconv PROPERTIES
            INTERFACE_INCLUDE_DIRECTORIES "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/include"
            INTERFACE_LINK_LIBRARIES "unofficial::iconv::libcharset"
        )
        
        set (Iconv_FOUND TRUE)
    endif ()
endif()
