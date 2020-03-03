set(MAJOR 5)
set(MINOR 14)
set(REVISION 1)
set(VERSION ${MAJOR}.${MINOR}.${REVISION})
set(RELEASE official)
set(TARBALL_EXTENSION tar.xz)
set(SHASUM a2cc1eb8baee9c5b9414dd06c3a4a6fd2794af93866890decc2941bbce8017bc0e21de0df4782bfe4f40f14d92b174cc7acc07b0567709fae3dc92e274d404fd)
set(PACKAGE_NAME qt-everywhere-src-${VERSION})
set(PACKAGE ${PACKAGE_NAME}.${TARBALL_EXTENSION})

vcpkg_find_acquire_program(PYTHON3)

get_filename_component(PYTHON_DIR ${PYTHON3} DIRECTORY)
message(STATUS "Python directory: ${PYTHON_DIR}")
vcpkg_add_to_path(${PYTHON_DIR})

if (CMAKE_HOST_WIN32 AND NOT MINGW)
    vcpkg_find_acquire_program("JOM")
endif ()

set (OPTIONAL_ARGS)
if(NOT "tools" IN_LIST FEATURES)
    list(APPEND OPTIONAL_SKIPS -skip qttools)
endif ()

vcpkg_download_distfile(ARCHIVE
    URLS "http://download.qt.io/archive/qt/${MAJOR}.${MINOR}/${VERSION}/single/${PACKAGE}"
    FILENAME "${PACKAGE}"
    SHA512 ${SHASUM}
)

vcpkg_extract_source_archive_ex(
    ARCHIVE ${ARCHIVE}
    REF ${PORT}
    OUT_SOURCE_PATH SOURCE_PATH
    PATCHES
        #mingw-cmake-prl-file-has-no-lib-prefix.patch
        lld-link-win.patch
        fix-cmake-qtplugins-debug-config.patch
        qquickitemgrabber.patch
        opengles2-without-dynamic.patch
)

set(BUILD_DIR_REL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)
set(BUILD_DIR_DBG ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)

if (MINGW AND NOT CMAKE_CROSSCOMPILING)
    set (FILES_TO_FIX
        qtbase/include/QtEventDispatcherSupport/${VERSION}/QtEventDispatcherSupport/private/qwindowsguieventdispatcher_p.h
        qtbase/include/QtFontDatabaseSupport/${VERSION}/QtFontDatabaseSupport/private/qwindowsfontdatabase_ft_p.h
        qtbase/include/QtWindowsUIAutomationSupport/${VERSION}/QtWindowsUIAutomationSupport/private/qwindowsuiawrapper_p.h
    )

    foreach(FILE_TO_FIX IN LISTS FILES_TO_FIX)
        # fix for include going wrong on native mingw build
        vcpkg_replace_string(${SOURCE_PATH}/${FILE_TO_FIX}
            "../../../../../"
            "../../../../"
        )
    endforeach()
endif ()

# copy the g++-cluster compiler specification
file(COPY ${CMAKE_CURRENT_LIST_DIR}/linux-g++-cluster DESTINATION ${SOURCE_PATH}/qtbase/mkspecs)

set(OPTIONAL_ARGS)
if(NOT "tools" IN_LIST FEATURES)
    list(APPEND OPTIONAL_ARGS -skip qttools)
endif()

if(NOT "qml" IN_LIST FEATURES)
    list(APPEND OPTIONAL_ARGS -skip qtquickcontrols -skip qtquickcontrols2 -skip qtdeclarative)
else()
    list(APPEND OPTIONAL_ARGS
        -no-feature-geoservices_mapbox
        -no-feature-geoservices_mapboxgl
    )
endif()

if(NOT "location" IN_LIST FEATURES)
    list(APPEND OPTIONAL_ARGS -skip qtlocation)
endif()

if(NOT "sql" IN_LIST FEATURES)
    list(APPEND OPTIONAL_ARGS -no-feature-sql -no-sql-db2 -no-sql-ibase -no-sql-mysql -no-sql-oci -no-sql-odbc -no-sql-psql -no-sql-sqlite2 -no-sql-sqlite -no-sql-tds)
else ()
    list(APPEND OPTIONAL_ARGS -sql-sqlite -system-sqlite -no-sql-sqlite2 -no-sql-mysql -no-sql-psql -no-sql-db2 -no-sql-tds)
endif()

if("tiff" IN_LIST FEATURES)
    list(APPEND OPTIONAL_ARGS -system-tiff)
else ()
    list(APPEND OPTIONAL_ARGS -no-tiff)
endif()

if("ssl" IN_LIST FEATURES)
    list(APPEND OPTIONAL_ARGS -ssl)
    if (VCPKG_TARGET_IS_WINDOWS)
        list(APPEND OPTIONAL_ARGS -schannel)
    endif ()

    if (VCPKG_TARGET_IS_WINDOWS OR VCPKG_TARGET_IS_OSX)
        list(APPEND OPTIONAL_ARGS -no-openssl)
    endif ()
else ()
    list(APPEND OPTIONAL_ARGS -no-openssl)
endif()

if (VCPKT_TARGET_LINUX)
    list(APPEND OPTIONAL_ARGS -system-freetype -system-harfbuzz)
else ()
    list(APPEND OPTIONAL_ARGS -no-freetype -no-harfbuzz)
endif ()

set(QT_OPTIONS
    -I ${CURRENT_INSTALLED_DIR}/include
    -verbose
    -opensource
    -confirm-license
    -nomake examples
    -nomake tests
    -no-dbus
    -no-icu
    -no-glib
    -no-gif
    -no-webp
    -no-cups
    -no-angle
    -system-zlib
    -system-libpng
    -system-libjpeg
    -system-pcre
    -skip qtdoc
    -skip qt3d
    -skip qtactiveqt
    -skip qtcanvas3d
    -skip qtconnectivity
    -skip qtdatavis3d
    -skip qtgamepad
    -skip qtmultimedia
    -skip qtpurchasing
    -skip qtremoteobjects
    -skip qtscript
    -skip qtsensors
    -skip qtserialbus
    -skip qtserialport
    -skip qtscxml
    -skip qtspeech
    -skip qtvirtualkeyboard
    -skip qtwebengine
    -skip qtwebchannel
    -skip qtwebsockets
    -skip qtwebview
    ${OPTIONAL_ARGS}
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    list(APPEND QT_OPTIONS -static)
else ()
    list(APPEND QT_OPTIONS -shared)
endif ()

if(VCPKG_CRT_LINKAGE STREQUAL "static")
    list(APPEND QT_OPTIONS -static-runtime)
endif()

if (CMAKE_CXX_VISIBILITY_PRESET STREQUAL hidden)
    list(APPEND QT_OPTIONS -reduce-exports)
else ()
    list(APPEND QT_OPTIONS -no-reduce-exports)
endif ()

if (CMAKE_INTERPROCEDURAL_OPTIMIZATION)
    list(APPEND QT_OPTIONS -ltcg)
endif ()

include(ProcessorCount)
ProcessorCount(NUM_CORES)
set(BUILD_COMMAND make -j${NUM_CORES})
set(EXEC_COMMAND)

set(PLATFORM_OPTIONS)
if(VCPKG_TARGET_IS_WINDOWS)
    find_program(JOM jom)
    if (JOM)
        set(BUILD_COMMAND ${JOM})
    else ()
        find_program(NMAKE nmake REQUIRED)
        set(BUILD_COMMAND ${NMAKE})
    endif ()

    if("angle" IN_LIST FEATURES)
        list(APPEND PLATFORM_OPTIONS -opengl es2)
    else ()
        list(APPEND PLATFORM_OPTIONS -opengl desktop)
    endif()

    set(CONFIG_SUFFIX .bat)
    set(PLATFORM -platform win32-msvc2017)
    list(APPEND PLATFORM_OPTIONS -mp)
elseif(VCPKG_TARGET_IS_LINUX)
    if (HOST MATCHES "x86_64-unknown-linux-gnu")
        set(PLATFORM -platform linux-g++-cluster)
        list(APPEND PLATFORM_OPTIONS -no-opengl -sysroot ${CMAKE_SYSROOT})
    elseif (CMAKE_COMPILER_IS_GNUCXX)
        set(PLATFORM -platform linux-g++)
    else ()
        set(PLATFORM -platform linux-clang)
    endif ()
    list(APPEND PLATFORM_OPTIONS -no-pch -c++std c++17)
    #-device-option CROSS_COMPILE=${CROSS}
elseif(VCPKG_TARGET_IS_OSX)
    list(APPEND PLATFORM_OPTIONS -c++std c++17 -no-pch)

    # change the minumum deployment target so the c++17 features become available
    vcpkg_replace_string(${SOURCE_PATH}/qtbase/mkspecs/common/macx.conf
        "QMAKE_MACOSX_DEPLOYMENT_TARGET = 10.13"
        "QMAKE_MACOSX_DEPLOYMENT_TARGET = ${CMAKE_OSX_DEPLOYMENT_TARGET}"
    )
elseif (MINGW AND (CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux" OR CMAKE_HOST_SYSTEM_NAME STREQUAL "Darwin"))
    set(PLATFORM -xplatform win32-g++)
    list(APPEND PLATFORM_OPTIONS -opengl desktop)
elseif (MINGW)
    set (DIRECTX_SDK_DIR "c:/Program Files (x86)/Microsoft DirectX SDK (June 2010)/")
    if (NOT EXISTS ${DIRECTX_SDK_DIR})
        message (FATAL_ERROR "The DirectX SDK needs to be installed in: ${DIRECTX_SDK_DIR}")
    endif ()

    set(BUILD_COMMAND jom)
    set(ENV{DXSDK_DIR} "${DIRECTX_SDK_DIR}")
    vcpkg_replace_string(${SOURCE_PATH}/qtbase/src/angle/src/common/common.pri "Utilities\\\\bin\\\\x64\\\\fxc.exe" "Utilities/bin/x64/fxc.exe")
    vcpkg_replace_string(${SOURCE_PATH}/qtbase/src/angle/src/common/common.pri "Utilities\\\\bin\\\\x86\\\\fxc.exe" "Utilities/bin/x86/fxc.exe")

    set(PLATFORM -platform win32-g++)
    list(APPEND PLATFORM_OPTIONS -angle)
    set(EXEC_COMMAND sh)
endif()

set (CMAKE_FIND_ROOT_PATH_MODE_LIBRARY_BACKUP ${CMAKE_FIND_ROOT_PATH_MODE_LIBRARY})
set (CMAKE_FIND_ROOT_PATH_MODE_LIBRARY NEVER)
find_library(ZLIB_RELEASE NAMES z zlib PATHS "${CURRENT_INSTALLED_DIR}/lib" NO_DEFAULT_PATH)
find_library(ZLIB_DEBUG NAMES zd zlibd z zlib PATHS "${CURRENT_INSTALLED_DIR}/debug/lib" NO_DEFAULT_PATH)
find_library(JPEG_RELEASE NAMES jpeg jpeg-static PATHS "${CURRENT_INSTALLED_DIR}/lib" NO_DEFAULT_PATH)
find_library(JPEG_DEBUG NAMES jpeg jpeg-static jpegd jpeg-staticd PATHS "${CURRENT_INSTALLED_DIR}/debug/lib" NO_DEFAULT_PATH)
find_library(LIBPNG_RELEASE NAMES png libpng PATHS "${CURRENT_INSTALLED_DIR}/lib" NO_DEFAULT_PATH) #Depends on zlib
find_library(LIBPNG_DEBUG NAMES png pngd libpng libpngd PATHS "${CURRENT_INSTALLED_DIR}/debug/lib" NO_DEFAULT_PATH)
find_library(PCRE2_RELEASE NAMES pcre2-16 PATHS "${CURRENT_INSTALLED_DIR}/lib" NO_DEFAULT_PATH)
find_library(PCRE2_DEBUG NAMES pcre2-16 pcre2-16d PATHS "${CURRENT_INSTALLED_DIR}/debug/lib" NO_DEFAULT_PATH)
#find_library(FREETYPE_RELEASE NAMES freetype PATHS "${CURRENT_INSTALLED_DIR}/lib" NO_DEFAULT_PATH) #zlib, bzip2, libpng
#find_library(FREETYPE_DEBUG NAMES freetype freetyped PATHS "${CURRENT_INSTALLED_DIR}/debug/lib" NO_DEFAULT_PATH)
#find_library(DOUBLECONVERSION_RELEASE NAMES double-conversion PATHS "${CURRENT_INSTALLED_DIR}/lib" NO_DEFAULT_PATH) 
#find_library(DOUBLECONVERSION_DEBUG NAMES double-conversion PATHS "${CURRENT_INSTALLED_DIR}/debug/lib" NO_DEFAULT_PATH)
#find_library(HARFBUZZ_RELEASE NAMES harfbuzz PATHS "${CURRENT_INSTALLED_DIR}/lib" NO_DEFAULT_PATH) 
#find_library(HARFBUZZ_DEBUG NAMES harfbuzz PATHS "${CURRENT_INSTALLED_DIR}/debug/lib" NO_DEFAULT_PATH)

set(QT_OPTIONS_REL
    -release
    -L ${CURRENT_INSTALLED_DIR}/lib
    -prefix ${CURRENT_INSTALLED_DIR}
    -extprefix ${CURRENT_PACKAGES_DIR}
    -hostbindir ${CURRENT_PACKAGES_DIR}/tools
    -archdatadir ${CURRENT_PACKAGES_DIR}/share/qt5
    -datadir ${CURRENT_PACKAGES_DIR}/share/qt5
    -plugindir ${CURRENT_PACKAGES_DIR}/plugins
    -qmldir ${CURRENT_PACKAGES_DIR}/qml
    "ZLIB_LIBS=${ZLIB_RELEASE}"
    "LIBJPEG_LIBS=${JPEG_RELEASE}"
    "LIBPNG_LIBS=${LIBPNG_RELEASE} ${ZLIB_RELEASE}"
    "PCRE2_LIBS=${PCRE2_RELEASE}"
    #"FREETYPE_LIBS=${FREETYPE_RELEASE} ${BZ2_RELEASE} ${LIBPNG_RELEASE} ${ZLIB_RELEASE}"
    #"ICU_LIBS=${ICU_RELEASE}"
    #"QMAKE_LIBS_PRIVATE+=${BZ2_RELEASE}"
    "QMAKE_LIBS_PRIVATE+=${LIBPNG_RELEASE}"
)

set(QT_OPTIONS_DBG
    -debug
    -L ${CURRENT_INSTALLED_DIR}/debug/lib
    -prefix ${CURRENT_INSTALLED_DIR}
    -libdir ${CURRENT_PACKAGES_DIR}/debug/lib
    -extprefix ${CURRENT_PACKAGES_DIR}
    -archdatadir ${CURRENT_PACKAGES_DIR}/debug/share/qt5
    -hostbindir ${CURRENT_PACKAGES_DIR}/debug/tools
    -archdatadir ${CURRENT_PACKAGES_DIR}/share/qt5/debug
    -datadir ${CURRENT_PACKAGES_DIR}/share/qt5/debug
    -plugindir ${CURRENT_PACKAGES_DIR}/debug/plugins
    -qmldir ${CURRENT_PACKAGES_DIR}/debug/qml
    -headerdir ${CURRENT_PACKAGES_DIR}/debug/include
    "ZLIB_LIBS=${ZLIB_DEBUG}"
    "LIBJPEG_LIBS=${JPEG_DEBUG}"
    "LIBPNG_LIBS=${LIBPNG_DEBUG} ${ZLIB_DEBUG}"
    "PCRE2_LIBS=${PCRE2_DEBUG}"
    #"FREETYPE_LIBS=${FREETYPE_DEBUG} ${BZ2_DEBUG} ${LIBPNG_DEBUG} ${ZLIB_DEBUG}"
    #"ICU_LIBS=${ICU_DEBUG}"
    #"QMAKE_LIBS_PRIVATE+=${BZ2_DEBUG}"
)

if("sql" IN_LIST FEATURES)
    #find_library(PSQL_RELEASE NAMES pq libpq PATHS "${CURRENT_INSTALLED_DIR}/lib" NO_DEFAULT_PATH) # Depends on openssl and zlib(linux)
    #find_library(PSQL_DEBUG NAMES pq libpq pqd libpqd PATHS "${CURRENT_INSTALLED_DIR}/debug/lib" NO_DEFAULT_PATH)
    find_library(SQLITE_RELEASE NAMES sqlite3 PATHS "${CURRENT_INSTALLED_DIR}/lib" NO_DEFAULT_PATH)
    find_library(SQLITE_DEBUG NAMES sqlite3 sqlite3d PATHS "${CURRENT_INSTALLED_DIR}/debug/lib" NO_DEFAULT_PATH)
    if (VCPKG_TARGET_IS_WINDOWS)
        list(APPEND QT_OPTIONS_REL "SQLITE_LIBS=${SQLITE_RELEASE}")
        list(APPEND QT_OPTIONS_DBG "SQLITE_LIBS=${SQLITE_DEBUG}")
    elseif (VCPKG_TARGET_IS_OSX)
        list(APPEND QT_OPTIONS_REL "SQLITE_LIBS=${SQLITE_RELEASE} -lpthread")
        list(APPEND QT_OPTIONS_DBG "SQLITE_LIBS=${SQLITE_DEBUG} -lpthread")
    else ()
        list(APPEND QT_OPTIONS_REL "SQLITE_LIBS=${SQLITE_RELEASE} -ld -lpthread")
        list(APPEND QT_OPTIONS_DBG "SQLITE_LIBS=${SQLITE_DEBUG} -ld -lpthread")
    endif ()
endif()

if("tiff" IN_LIST FEATURES)
    find_library(LZMA_RELEASE NAMES lzma PATHS "${CURRENT_INSTALLED_DIR}/lib" NO_DEFAULT_PATH)
    find_library(LZMA_DEBUG NAMES lzmad PATHS "${CURRENT_INSTALLED_DIR}/debug/lib" NO_DEFAULT_PATH)
    find_library(TIFF_RELEASE NAMES tiff PATHS "${CURRENT_INSTALLED_DIR}/lib" NO_DEFAULT_PATH)
    find_library(TIFF_DEBUG NAMES tiffd PATHS "${CURRENT_INSTALLED_DIR}/debug/lib" NO_DEFAULT_PATH)
    list(APPEND QT_OPTIONS_REL "TIFF_LIBS=${TIFF_RELEASE} ${LZMA_RELEASE} ${ZLIB_RELEASE}")
    list(APPEND QT_OPTIONS_DBG "TIFF_LIBS=${TIFF_DEBUG} ${LZMA_DEBUG} ${ZLIB_DEBUG}")
endif()

if ("angle" IN_LIST FEATURES)
    unset(PLATFORM)
    set(GL_LIBDIR ${CURRENT_INSTALLED_DIR}/lib)
    configure_file(${CMAKE_CURRENT_LIST_DIR}/qmake-msvc.conf.in ${SOURCE_PATH}/qtbase/mkspecs/msvc-angle-rel/qmake.conf)
    file(COPY ${SOURCE_PATH}/qtbase/mkspecs/win32-msvc/qplatformdefs.h DESTINATION ${SOURCE_PATH}/qtbase/mkspecs/msvc-angle-rel)
    list(APPEND QT_OPTIONS_REL -platform msvc-angle-rel)
    
    set(GL_LIBDIR ${CURRENT_INSTALLED_DIR}/debug/lib)
    set(GL_DEBUG_POSTFIX d)
    configure_file(${CMAKE_CURRENT_LIST_DIR}/qmake-msvc.conf.in ${SOURCE_PATH}/qtbase/mkspecs/msvc-angle-dbg/qmake.conf)
    file(COPY ${SOURCE_PATH}/qtbase/mkspecs/win32-msvc/qplatformdefs.h DESTINATION ${SOURCE_PATH}/qtbase/mkspecs/msvc-angle-dbg)
    list(APPEND QT_OPTIONS_DBG -platform msvc-angle-dbg)
endif ()

list(APPEND QT_OPTIONS ${PLATFORM} ${PLATFORM_OPTIONS})
set (CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ${CMAKE_FIND_ROOT_PATH_MODE_LIBRARY_BACKUP})
file(REMOVE_RECURSE ${BUILD_DIR_REL} ${BUILD_DIR_DBG})

set(ENV{PKG_CONFIG_LIBDIR} "${CURRENT_INSTALLED_DIR}/lib/pkgconfig")
message(STATUS "Configuring ${TARGET_TRIPLET}-dbg")
if(VCPKG_VERBOSE)
    STRING(JOIN " " QT_ARGS ${QT_OPTIONS} ${QT_OPTIONS_DBG})
    message(STATUS "${SOURCE_PATH}/configure${CONFIG_SUFFIX} ${QT_ARGS}")
endif()
file(MAKE_DIRECTORY ${BUILD_DIR_DBG})
vcpkg_execute_required_process(
    COMMAND ${EXEC_COMMAND} ${SOURCE_PATH}/configure${CONFIG_SUFFIX} ${QT_OPTIONS} ${QT_OPTIONS_DBG}
    WORKING_DIRECTORY ${BUILD_DIR_DBG}
    LOGNAME qt-configure-${TARGET_TRIPLET}-debug
)

message(STATUS "Configuring ${TARGET_TRIPLET}-rel")
if(VCPKG_VERBOSE)
    STRING(JOIN " " QT_ARGS ${QT_OPTIONS} ${QT_OPTIONS_REL})
    message(STATUS "${SOURCE_PATH}/configure${CONFIG_SUFFIX} ${QT_ARGS}")
endif ()
file(MAKE_DIRECTORY ${BUILD_DIR_REL})
vcpkg_execute_required_process(
    COMMAND ${EXEC_COMMAND} ${SOURCE_PATH}/configure${CONFIG_SUFFIX} ${QT_OPTIONS} ${QT_OPTIONS_REL}
    WORKING_DIRECTORY ${BUILD_DIR_REL}
    LOGNAME qt-configure-${TARGET_TRIPLET}-release
)

message(STATUS "Building ${TARGET_TRIPLET}-dbg")
# build the binary target not included in all (otherwise the install step fails)
vcpkg_execute_required_process(
    COMMAND ${BUILD_COMMAND} binary
    WORKING_DIRECTORY ${BUILD_DIR_DBG}/qtbase/qmake
)
vcpkg_execute_required_process(
    COMMAND ${BUILD_COMMAND} install
    WORKING_DIRECTORY ${BUILD_DIR_DBG}
    LOGNAME qt-build-${TARGET_TRIPLET}-debug
)

message(STATUS "Building ${TARGET_TRIPLET}-rel")
vcpkg_execute_required_process(
    COMMAND ${BUILD_COMMAND} binary
    WORKING_DIRECTORY ${BUILD_DIR_REL}/qtbase/qmake
)
vcpkg_execute_required_process(
    COMMAND ${BUILD_COMMAND} install
    WORKING_DIRECTORY ${BUILD_DIR_REL}
    LOGNAME qt-build-${TARGET_TRIPLET}-release
)

configure_file(${CMAKE_CURRENT_LIST_DIR}/qt_debug.conf ${CURRENT_PACKAGES_DIR}/tools/qt_debug.conf)
configure_file(${CMAKE_CURRENT_LIST_DIR}/qt_release.conf ${CURRENT_PACKAGES_DIR}/tools/qt_release.conf)

file(RENAME ${CURRENT_PACKAGES_DIR}/lib/cmake ${CURRENT_PACKAGES_DIR}/share/cmake)

if("location" IN_LIST FEATURES)
   vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/share/cmake/Qt5Location/Qt5LocationConfig.cmake "Qt5Location_*Plugin.cmake" "Qt5Location_*Factory*.cmake")
endif()

file(GLOB BIN_FILES ${CURRENT_PACKAGES_DIR}/bin/*)
file(COPY ${BIN_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/tools)
file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/bin
    ${CURRENT_PACKAGES_DIR}/debug/tools
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig
    ${CURRENT_PACKAGES_DIR}/debug/lib/cmake
    ${CURRENT_PACKAGES_DIR}/debug/share
    ${CURRENT_PACKAGES_DIR}/bin
)

if (VCPKG_TARGET_IS_WINDOWS AND "angle" IN_LIST FEATURES)
    # egl library names get added to the prl files without path
    # turn it into an absolute path
    file(GLOB_RECURSE PRL_FILES ${CURRENT_PACKAGES_DIR}/*.prl)
    foreach(PRL_FILE ${PRL_FILES})
        vcpkg_replace_string(${PRL_FILE} " libEGL.lib " " $$[QT_INSTALL_LIBS]/libEGL.lib ")
        vcpkg_replace_string(${PRL_FILE} ";libEGL.lib;" ";$$[QT_INSTALL_LIBS]/libEGL.lib;")
        vcpkg_replace_string(${PRL_FILE} " libGLESv2.lib " " $$[QT_INSTALL_LIBS]/libGLESv2.lib ")
        vcpkg_replace_string(${PRL_FILE} ";libGLESv2.lib;" ";$$[QT_INSTALL_LIBS]/libGLESv2.lib;")
        vcpkg_replace_string(${PRL_FILE} " libEGLd.lib " " $$[QT_INSTALL_LIBS]/libEGLd.lib ")
        vcpkg_replace_string(${PRL_FILE} ";libEGLd.lib;" ";$$[QT_INSTALL_LIBS]/libEGLd.lib;")
        vcpkg_replace_string(${PRL_FILE} " libGLESv2d.lib " " $$[QT_INSTALL_LIBS]/libGLESv2d.lib ")
        vcpkg_replace_string(${PRL_FILE} ";libGLESv2d.lib;" ";$$[QT_INSTALL_LIBS]/libGLESv2d.lib;")
    endforeach()
endif ()

# bootstrap libs are only used for the tools and cause errors on windows as they link to a different crt
file(REMOVE
    ${CURRENT_PACKAGES_DIR}/debug/lib/Qt5Bootstrap.lib
    ${CURRENT_PACKAGES_DIR}/debug/lib/Qt5Bootstrap.prl
    ${CURRENT_PACKAGES_DIR}/lib/Qt5Bootstrap.lib
    ${CURRENT_PACKAGES_DIR}/lib/Qt5Bootstrap.prl
)

file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/FindQmlPlugin.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/cmake)
file(INSTALL ${SOURCE_PATH}/LICENSE.LGPLv3 DESTINATION  ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
