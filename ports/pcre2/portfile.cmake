set(PCRE2_VERSION 10.36)
vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.pcre.org/pub/pcre/pcre2-${PCRE2_VERSION}.zip" "https://sourceforge.net/projects/pcre/files/pcre2/${PCRE2_VERSION}/pcre2-${PCRE2_VERSION}.zip/download"
    FILENAME "pcre2-${PCRE2_VERSION}.zip"
    SHA512 68f5984a786f77e298d33a55260ff23709cc959b6085fe6f4c4e70c1db8531f177e8e26b03fab114cfc200cf919c340aaba463bb2d0e978e635184098ed45b9f)

vcpkg_extract_source_archive_ex(
    ARCHIVE ${ARCHIVE}
    OUT_SOURCE_PATH SOURCE_PATH
)

set(SUPPORT_JIT ON)
if (${TARGET_TRIPLET} STREQUAL "arm64-osx")
    set(SUPPORT_JIT OFF)
endif ()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DPCRE2_BUILD_PCRE2_8=ON
        -DPCRE2_BUILD_PCRE2_16=ON
        -DPCRE2_BUILD_PCRE2_32=ON
        -DPCRE2_SUPPORT_JIT=${SUPPORT_JIT}
        -DPCRE2_SUPPORT_UNICODE=ON
        -DPCRE2_BUILD_TESTS=OFF
        -DPCRE2_BUILD_PCRE2GREP=OFF)

vcpkg_install_cmake()

file(READ ${CURRENT_PACKAGES_DIR}/include/pcre2.h PCRE2_H)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    string(REPLACE "defined(PCRE2_STATIC)" "1" PCRE2_H "${PCRE2_H}")
else()
    string(REPLACE "defined(PCRE2_STATIC)" "0" PCRE2_H "${PCRE2_H}")
endif()
file(WRITE ${CURRENT_PACKAGES_DIR}/include/pcre2.h "${PCRE2_H}")

# don't install POSIX wrapper
file(REMOVE ${CURRENT_PACKAGES_DIR}/include/pcre2posix.h)
file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/pcre2-posix.lib ${CURRENT_PACKAGES_DIR}/debug/lib/pcre2-posixd.lib)
file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/pcre2-posix.dll ${CURRENT_PACKAGES_DIR}/debug/bin/pcre2-posixd.dll)

vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/man)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share/doc)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/man)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/pcre2)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/pcre2/COPYING ${CURRENT_PACKAGES_DIR}/share/pcre2/copyright)
