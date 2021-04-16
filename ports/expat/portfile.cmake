set(MAJOR 2)
set(MINOR 3)
set(REVISION 0)
set(VERSION R_${MAJOR}_${MINOR}_${REVISION})

include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libexpat/libexpat
    REF ${VERSION}
    SHA512 728ceb1d912fabc7662d4201828dc29c7fdaff124a1d6dc81434b1951eb530b17f1bbb1aec22c1520543cff3844f4751f29d3c59b696dd8a56598abdc25e1d08
    HEAD_REF master
    PATCHES winpostfix.patch
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
        -DEXPAT_BUILD_EXAMPLES=OFF
        -DEXPAT_BUILD_TESTS=OFF
        -DEXPAT_BUILD_TOOLS=OFF
        -DEXPAT_BUILD_DOCS=OFF
        -DEXPAT_SHARED_LIBS=${EXPAT_LINKAGE}
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig)
file(INSTALL ${SOURCE_PATH}/expat/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/expat RENAME copyright)

vcpkg_fixup_pkgconfig_file()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/cmake")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/cmake")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/doc")

file(READ ${CURRENT_PACKAGES_DIR}/include/expat_external.h EXPAT_EXTERNAL_H)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    string(REPLACE "!defined(XML_STATIC)" "/* vcpkg static build !defined(XML_STATIC) */ 0" EXPAT_EXTERNAL_H "${EXPAT_EXTERNAL_H}")
endif()
file(WRITE ${CURRENT_PACKAGES_DIR}/include/expat_external.h "${EXPAT_EXTERNAL_H}")

vcpkg_test_cmake(PACKAGE_NAME EXPAT MODULE REQUIRED_HEADER expat.h TARGETS EXPAT::EXPAT)
