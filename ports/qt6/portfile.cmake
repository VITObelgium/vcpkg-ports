set(MAJOR 6)
set(MINOR 1)
set(REVISION 1)
set(VERSION ${MAJOR}.${MINOR}.${REVISION})
set(RELEASE official)
set(PACKAGE_NAME qt-everywhere-src-${VERSION})
set(PACKAGE ${PACKAGE_NAME}.tar.xz)

vcpkg_download_distfile(ARCHIVE
    URLS "http://download.qt.io/archive/qt/${MAJOR}.${MINOR}/${VERSION}/single/${PACKAGE}"
    FILENAME "${PACKAGE}"
    SHA512 fd6504967039fd3dd577ab2c23b36f2d10e139832eed1b1d7900bff26d511ca79ae445b396c9415cfb19f83f904b4c3fe83222e24ba96bedf864032f9ad6290b
)

vcpkg_extract_source_archive_ex(
    ARCHIVE ${ARCHIVE}
    REF ${PORT}
    OUT_SOURCE_PATH SOURCE_PATH
    PATCHES config_install.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
FEATURES
    "qml"           FEATURE_qml
    "location"      FEATURE_location
    "sql"           FEATURE_sql
    "ssl"           FEATURE_ssl
    "tools"         FEATURE_tools
    "charts"        FEATURE_charts
    "tiff"          FEATURE_tiff
)

vcpkg_find_acquire_program(PYTHON3)
vcpkg_find_acquire_program(PERL)

get_filename_component(PYTHON_DIR ${PYTHON3} DIRECTORY)
message(STATUS "Python directory: ${PYTHON_DIR}")
vcpkg_add_to_path(${PYTHON_DIR})

get_filename_component(PERL_DIR ${PERL} DIRECTORY)
message(STATUS "Perl directory: ${PERL_DIR}")
vcpkg_add_to_path(${PERL_DIR})

set(OPTIONAL_ARGS)
set(OPTIONAL_CMAKE_ARGS)

set(QT_OPTIONS
    -I ${CURRENT_INSTALLED_DIR}/include
    -nomake examples
    -nomake tests
    -no-dbus
    -no-icu
    -no-glib
    -no-webp
    -no-cups
    -no-feature-zstd
    -no-feature-accessibility
    -system-zlib
    -system-libpng
    -system-libjpeg
    -system-pcre
    -skip qtdoc
    -skip qt3d
    -skip qtquick3d
    -skip qtshadertools
    -skip qt5compat
    -skip qtcanvas3d
    -skip qtconnectivity
    -skip qtdatavis3d
    -skip qtcharts
    -skip qtdeclarative
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
    -skip qtcoap
    -skip qtmqtt
    -skip qtopcua
    ${OPTIONAL_ARGS}
)

set(EXEC_COMMAND)

set(PLATFORM_OPTIONS)
if(VCPKG_TARGET_IS_WINDOWS)
    list(APPEND PLATFORM_OPTIONS -opengl desktop)

    set(CONFIG_SUFFIX .bat)
    list(APPEND QT_OPTIONS -platform win32-msvc2017)
    list(APPEND PLATFORM_OPTIONS -mp)
elseif(VCPKG_TARGET_IS_LINUX)
    if (HOST MATCHES "x86_64-unknown-linux-gnu")
        list(APPEND PLATFORM_OPTIONS -no-opengl -sysroot ${CMAKE_SYSROOT})
    elseif (CMAKE_COMPILER_IS_GNUCXX)
        set(PLATFORM -platform linux-g++)
    else ()
        set(PLATFORM -platform linux-clang)
    endif ()
    list(APPEND PLATFORM_OPTIONS -no-pch -c++std c++17)
    #-device-option CROSS_COMPILE=${CROSS}
elseif(VCPKG_TARGET_IS_OSX)
    list(APPEND PLATFORM_OPTIONS -c++std c++17 -no-pch -DCMAKE_OSX_ARCHITECTURES=${VCPKG_OSX_ARCHITECTURES})

    # change the minumum deployment target so the c++17 features become available
    vcpkg_replace_string(${SOURCE_PATH}/qtbase/mkspecs/common/macx.conf
        "QMAKE_MACOSX_DEPLOYMENT_TARGET = 10.13"
        "QMAKE_MACOSX_DEPLOYMENT_TARGET = ${VCPKG_OSX_DEPLOYMENT_TARGET}"
    )
elseif (MINGW AND (VCPKG_TARGET_IS_LINUX OR VCPKG_TARGET_IS_OSX))
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

list(APPEND QT_OPTIONS ${PLATFORM} ${PLATFORM_OPTIONS})

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

# set (CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ${CMAKE_FIND_ROOT_PATH_MODE_LIBRARY_BACKUP})

if (VCPKG_TARGET_IS_LINUX)
    set(FREETYPE_HARFBUZZ ON)
else ()
    set(FREETYPE_HARFBUZZ OFF)
endif ()

if (VCPKG_TARGET_IS_WINDOWS)
    set(DESKTOP_OPENGL ON)
    set(DYNAMIC_OPENGL OFF)
else ()
    set(DESKTOP_OPENGL OFF)
endif ()

if (VCPKG_TARGET_IS_OSX)
    set(ALLOW_SYSTEM_LIBS ON)
else ()
    set(ALLOW_SYSTEM_LIBS OFF)
endif()

set(QT6_DIRECTORY_PREFIX "qt6/")
set(qt_plugindir ${QT6_DIRECTORY_PREFIX}plugins)
set(qt_qmldir ${QT6_DIRECTORY_PREFIX}qml)

vcpkg_configure_cmake(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DINSTALL_BINDIR:STRING=tools/qt6
        -DINSTALL_LIBEXECDIR:STRING=bin
        -DINSTALL_PLUGINSDIR:STRING=${qt_plugindir}
        -DINSTALL_QMLDIR:STRING=${qt_qmldir}
        -DINSTALL_DOCDIR:STRING=doc/${QT6_DIRECTORY_PREFIX}
        -DINSTALL_INCLUDEDIR:STRING=include/${QT6_DIRECTORY_PREFIX}
        -DINSTALL_DESCRIPTIONSDIR:STRING=share/qt6/modules
        -DINSTALL_MKSPECSDIR:STRING=share/qt6/mkspecs
        -DINSTALL_TRANSLATIONSDIR:STRING=translations/${QT6_DIRECTORY_PREFIX}

        -DVCPKG_ALLOW_SYSTEM_LIBS=${ALLOW_SYSTEM_LIBS}
        -DQT_NO_MAKE_EXAMPLES:BOOL=TRUE
        -DQT_NO_MAKE_TESTS:BOOL=TRUE
        -DFEATURE_cpus=OFF
        -DFEATURE_webp=OFF
        -DFEATURE_dbus=OFF
        -DFEATURE_zstd=OFF
        -DFEATURE_icu=OFF
        -DFEATURE_pdf=OFF
        -DFEATURE_glib=OFF
        -DFEATURE_accessibility=OFF
        -DFEATURE_brotli=OFF
        
        -DINPUT_opengl=desktop
        -DFEATURE_opengl=ON
        -DFEATURE_opengl_desktop=ON
        
        -DFEATURE_system_zlib=ON
        -DFEATURE_system_png=ON
        -DFEATURE_system_pcre2=ON
        -DFEATURE_system_jpeg=ON
        -DFEATURE_freetype=${FREETYPE_HARFBUZZ}
        -DFEATURE_harfbuzz=${FREETYPE_HARFBUZZ}
        -DFEATURE_system_freetype=${FREETYPE_HARFBUZZ}
        -DFEATURE_system_harfbuzz=${FREETYPE_HARFBUZZ}
        
        -DBUILD_qtactiveqt=OFF
        -DBUILD_qtdoc=OFF
        -DBUILD_qt3d=OFF
        -DBUILD_qtquick3d=OFF
        -DBUILD_qtshadertools=OFF
        -DBUILD_qt5compat=OFF
        -DBUILD_qtcanvas3d=OFF
        -DBUILD_qtconnectivity=OFF
        -DBUILD_qtdatavis3d=OFF
        -DBUILD_qtcharts=${FEATURE_charts}
        -DBUILD_qtdeclarative=OFF
        -DBUILD_qtmultimedia=OFF
        -DBUILD_qtpurchasing=OFF
        -DBUILD_qtremoteobjects=OFF
        -DBUILD_qtscript=OFF
        -DBUILD_qtsensors=OFF
        -DBUILD_qtserialbus=OFF
        -DBUILD_qtserialport=OFF
        -DBUILD_qtscxml=OFF
        -DBUILD_qtspeech=OFF
        -DBUILD_qtvirtualkeyboard=OFF
        -DBUILD_qtwebengine=OFF
        -DBUILD_qtwebchannel=OFF
        -DBUILD_qtwebsockets=OFF
        -DBUILD_qtwebview=OFF
        -DBUILD_qtcoap=OFF
        -DBUILD_qtmqtt=OFF
        -DBUILD_qtopcua=OFF
        ${OPTIONAL_CMAKE_ARGS}

        -DBUILD_qttools=${FEATURE_tools}
        -DBUILD_qttranslations=${FEATURE_tools}

        -DBUILD_qtquickcontrols=${FEATURE_qml}
        -DBUILD_qtquickcontrols2=${FEATURE_qml}
        -DBUILD_qtlottie=${FEATURE_qml}
        -DBUILD_qtquicktimeline=${FEATURE_qml}
        -DBUILD_qtdeclarative=${FEATURE_qml}
        -DBUILD_qtwayland=${FEATURE_qml}
        -DFEATURE_d3d12=OFF # d3d12 is not available on windows server 2012

        -DBUILD_qtlocation=${FEATURE_location}
        -DFEATURE_geoservices_here=OFF
        -DFEATURE_geoservices_mapbox=OFF
        -DFEATURE_geoservices_mapboxgl=OFF

        -DFEATURE_ssl=${FEATURE_ssl}
        -DFEATURE_securetransport=${FEATURE_ssl}
        -DFEATURE_=${FEATURE_ssl}

        -DFEATURE_sql=${FEATURE_sql}
        # -no-sql-db2
        # -no-sql-ibase
        # -no-sql-mysql
        # -no-sql-oci
        # -no-sql-odbc
        # -no-sql-psql
        # -no-sql-sqlite

        -DCMAKE_FEATURE_TIFF=${FEATURE_tiff}
        -DFEATURE_system_tiff=ON
        
    OPTIONS_DEBUG
        -DINPUT_debug:BOOL=ON
        -DQT_NO_MAKE_TOOLS:BOOL=ON
)
vcpkg_install_cmake()
vcpkg_copy_pdbs()

# process cmake files
set(COMPONENTS)
file(GLOB COMPONENTS_OR_FILES LIST_DIRECTORIES true "${CURRENT_PACKAGES_DIR}/share/Qt6*")
list(REMOVE_ITEM COMPONENTS_OR_FILES "${CURRENT_PACKAGES_DIR}/share/qt6")
foreach(_glob IN LISTS COMPONENTS_OR_FILES)
    if(IS_DIRECTORY "${_glob}")
        string(REPLACE "${CURRENT_PACKAGES_DIR}/share/Qt6" "" _component "${_glob}")
        message(STATUS "Adding cmake component: '${_component}'")
        list(APPEND COMPONENTS ${_component})
    endif()
endforeach()

foreach(_comp IN LISTS COMPONENTS)
    if(EXISTS "${CURRENT_PACKAGES_DIR}/share/Qt6${_comp}")
        vcpkg_fixup_cmake_targets(CONFIG_PATH share/Qt6${_comp} TARGET_PATH share/Qt6${_comp})
        # Would rather put it into share/cmake as before but the import_prefix correction in vcpkg_fixup_cmake_targets is working against that. 
    else()
        message(STATUS "WARNING: Qt component ${_comp} not found/built!")
    endif()
endforeach()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/tools")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/cmake")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/cmake")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/Qt6/QtBuildInternals")

if(NOT VCPKG_TARGET_IS_IOS)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/Qt6/ios")
endif()

if(NOT VCPKG_TARGET_IS_OSX)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/Qt6/macos")
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

#configure_file(${CMAKE_CURRENT_LIST_DIR}/qt_debug.conf ${CURRENT_PACKAGES_DIR}/tools/qt_debug.conf)
#configure_file(${CMAKE_CURRENT_LIST_DIR}/qt_release.conf ${CURRENT_PACKAGES_DIR}/tools/qt_release.conf)

# file(RENAME ${CURRENT_PACKAGES_DIR}/lib/cmake ${CURRENT_PACKAGES_DIR}/share/cmake)

# file(GLOB BIN_FILES ${CURRENT_PACKAGES_DIR}/bin/*)
# file(COPY ${BIN_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/tools)
# file(REMOVE_RECURSE
#     ${CURRENT_PACKAGES_DIR}/debug/bin
#     ${CURRENT_PACKAGES_DIR}/debug/tools
#     ${CURRENT_PACKAGES_DIR}/debug/include
#     ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig
#     ${CURRENT_PACKAGES_DIR}/debug/lib/cmake
#     ${CURRENT_PACKAGES_DIR}/debug/share
#     ${CURRENT_PACKAGES_DIR}/bin
# )

# # bootstrap libs are only used for the tools and cause errors on windows as they link to a different crt
# file(REMOVE
#     ${CURRENT_PACKAGES_DIR}/debug/lib/Qt5Bootstrap.lib
#     ${CURRENT_PACKAGES_DIR}/debug/lib/Qt5Bootstrap.prl
#     ${CURRENT_PACKAGES_DIR}/lib/Qt5Bootstrap.lib
#     ${CURRENT_PACKAGES_DIR}/lib/Qt5Bootstrap.prl
# )

# file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/FindQmlPlugin.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/cmake)
file(INSTALL ${SOURCE_PATH}/LICENSE.LGPLv3 DESTINATION  ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
