set(MAJOR 2)
set(MINOR 2)
set(REVISION 7)
set(VERSION R_${MAJOR}_${MINOR}_${REVISION})

include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libexpat/libexpat
    REF ${VERSION}
    SHA512 11b1f9a135c4501ef0112e17da8381e956366165a11a384daedd4cdef9a00c3112c8f6ff8c8f6d3b5e7b71b9a73041f23beac0f27e9cfafe1ec0266d95870408
    HEAD_REF master
)

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL Emscripten)
    # fix arc4random implicit declaration when using emscripten
    message(STATUS "Applying arc4random patch")
    vcpkg_replace_string(${SOURCE_PATH}/expat/lib/xmlparse.c "#include <stdio.h>" "unsigned int arc4random(void);\n#include <stdio.h>")
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(EXPAT_LINKAGE ON)
else()
    set(EXPAT_LINKAGE OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/expat
    PREFER_NINJA
    OPTIONS
        -DBUILD_examples=OFF
        -DBUILD_tests=OFF
        -DBUILD_tools=OFF
        -DBUILD_shared=${EXPAT_LINKAGE}
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig)
file(INSTALL ${SOURCE_PATH}/expat/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/expat RENAME copyright)

vcpkg_fixup_pkgconfig_file()
vcpkg_copy_pdbs()

file(READ ${CURRENT_PACKAGES_DIR}/include/expat_external.h EXPAT_EXTERNAL_H)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    string(REPLACE "!defined(XML_STATIC)" "/* vcpkg static build !defined(XML_STATIC) */ 0" EXPAT_EXTERNAL_H "${EXPAT_EXTERNAL_H}")
endif()
file(WRITE ${CURRENT_PACKAGES_DIR}/include/expat_external.h "${EXPAT_EXTERNAL_H}")
