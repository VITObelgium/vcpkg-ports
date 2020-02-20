if(NOT TARGET LibXml2::LibXml2)
    find_package(LibLZMA QUIET REQUIRED)
    find_package(unofficial-iconv CONFIG QUIET REQUIRED)
    add_library(LibXml2::LibXml2 STATIC IMPORTED)
    set_target_properties(LibXml2::LibXml2 PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/include"
        INTERFACE_LINK_LIBRARIES "LibLZMA::LibLZMA;unofficial::iconv::libcharset"
        IMPORTED_LOCATION "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib/libxml2${CMAKE_STATIC_LIBRARY_SUFFIX}"
        IMPORTED_LOCATION_DEBUG "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/lib/libxml2d${CMAKE_STATIC_LIBRARY_SUFFIX}"
    )
    set(LibXml2_FOUND TRUE)
endif()
