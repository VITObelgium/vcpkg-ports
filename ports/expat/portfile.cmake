set(MAJOR 2)
set(MINOR 4)
set(REVISION 1)
set(VERSION R_${MAJOR}_${MINOR}_${REVISION})

include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libexpat/libexpat
    REF ${VERSION}
    SHA512 1f08861e9b766fdbbc40159404a3fe1a86451d635ef81874fa3492845eda83ac2dc6a0272525891d396b70c9a9254c2f6c907fe4abb2f8a533ccd3f52dae9d5a
    HEAD_REF master
    PATCHES winpostfix.patch
)

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL Emscripten)
    # fix arc4random implicit declaration when using emscripten
    message(STATUS "Applying arc4random patch")
    vcpkg_replace_string(${SOURCE_PATH}/expat/lib/xmlparse.c "#include <stdio.h>" "unsigned int arc4random(void);\n#include <stdio.h>")
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/expat
    PREFER_NINJA
    OPTIONS
        -DEXPAT_BUILD_EXAMPLES=OFF
        -DEXPAT_BUILD_TESTS=OFF
        -DEXPAT_BUILD_TOOLS=OFF
        -DEXPAT_BUILD_DOCS=OFF
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
