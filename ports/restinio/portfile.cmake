include(vcpkg_common_functions)

set(VERSION_MAJOR 0)
set(VERSION_MINOR 6)
set(VERSION_REVISION 0)
set(VERSION ${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_REVISION})

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Stiffstream/restinio
    REF v.${VERSION}
    SHA512 70c37a9b88db5eef0591baf0adc8227c1103a4f272c8fcd332410b9481854f5ae8f2385c8070c7eab17e8a75e699cded528fc655fbdef3553203914abb379b3a
    HEAD_REF master
    PATCHES recursivedeps.patch
)

vcpkg_replace_string(${SOURCE_PATH}/dev/CMakeLists.txt "find_package(Catch2 CONFIG REQUIRED)" "")
vcpkg_replace_string(${SOURCE_PATH}/dev/restinio/CMakeLists.txt "fmt::fmt-header-only" "fmt::fmt")

if("boost" IN_LIST FEATURES)
    set(ASIO_OPT -DRESTINIO_USE_BOOST_ASIO=static)
elseif("asio" IN_LIST FEATURES)
    set(ASIO_OPT -DRESTINIO_USE_BOOST_ASIO=none)
else()
    message(FATAL_ERROR "boost or asio must be active as a feature")
endif()

set (USE_STATIC_CRT_VALUE OFF)
if(VCPKG_CRT_LINKAGE STREQUAL "static")
    set(USE_STATIC_CRT_VALUE ON)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/dev
    PREFER_NINJA
    OPTIONS
        -DRESTINIO_INSTALL=ON
        -DRESTINIO_TEST=OFF
        -DRESTINIO_SAMPLE=OFF
        -DRESTINIO_BENCH=OFF
        -DRESTINIO_ALLOW_SOBJECTIZER=OFF
        -DRESTINIO_FIND_DEPS=ON
        -DBoost_USE_STATIC_RUNTIME=${USE_STATIC_CRT_VALUE}
        ${ASIO_OPT}
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/restinio")

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib ${CURRENT_PACKAGES_DIR}/debug)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

