#header-only library
include(vcpkg_common_functions)

vcpkg_download_distfile(
	ARCHIVE_FILE
	URLS "https://netix.dl.sourceforge.net/project/asio/asio/1.12.2%20%28Stable%29/asio-1.12.2.zip"
	FILENAME "asio-1.12.2.zip"
	SHA512 f0e945a7c7bc25c15b375b76f3aaff7c6c2c2ca981d1ee207990d14425b23aee2365d295ae78c216b67d6f70cc9d99a8558a879f5c2cd882dc91f56e7e643cc4
)

vcpkg_extract_source_archive(
	${ARCHIVE_FILE}
)

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/asio-1.12.2)

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(RENAME ${CURRENT_PACKAGES_DIR}/share/${PORT}/COPYING ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright)

# Copy the asio header files
file(INSTALL ${SOURCE_PATH}/include DESTINATION ${CURRENT_PACKAGES_DIR} FILES_MATCHING PATTERN "*.hpp" PATTERN "*.ipp")

# Always use "ASIO_STANDALONE" to avoid boost dependency
file(READ "${CURRENT_PACKAGES_DIR}/include/asio/detail/config.hpp" _contents)
string(REPLACE "defined(ASIO_STANDALONE)" "!defined(VCPKG_DISABLE_ASIO_STANDALONE)" _contents "${_contents}")
file(WRITE "${CURRENT_PACKAGES_DIR}/include/asio/detail/config.hpp" "${_contents}")
