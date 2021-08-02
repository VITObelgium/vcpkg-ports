set(MAJOR 6)
set(MINOR 1)
set(REVISION 2)
set(VERSION ${MAJOR}.${MINOR}.${REVISION})
set(PACKAGE qt-everywhere-src-${VERSION}.tar.xz)

vcpkg_download_distfile(ARCHIVE
    URLS "http://download.qt.io/archive/qt/${MAJOR}.${MINOR}/${VERSION}/single/${PACKAGE}"
    FILENAME "${PACKAGE}"
    SHA512 8d249759bdb562f42085236e1e7f5100bfe325ab1efa945ca71a65eead9280d3ae1ccadfbe150267f8f1987391fbc8706283a2576558d39e1e1092f4e3f1aabc
)

vcpkg_extract_source_archive_ex(
    ARCHIVE ${ARCHIVE}
    REF ${PORT}
    OUT_SOURCE_PATH SOURCE_PATH
    PATCHES
        config_install.patch
        harfbuzz.patch
        angle.patch
        optional-printsupport.patch # included in next release
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
    "angle"         FEATURE_angle
)

vcpkg_find_acquire_program(PYTHON3)
vcpkg_find_acquire_program(PERL)

get_filename_component(PYTHON_DIR ${PYTHON3} DIRECTORY)
message(STATUS "Python directory: ${PYTHON_DIR}")
vcpkg_add_to_path(${PYTHON_DIR})

get_filename_component(PERL_DIR ${PERL} DIRECTORY)
message(STATUS "Perl directory: ${PERL_DIR}")
vcpkg_add_to_path(${PERL_DIR})

set(EXTRA_ARGS)
set(SECURETRANSPORT)

set (FREETYPE_HARFBUZZ system)
set (OPENGL desktop)
if (FEATURE_angle)
    set (OPENGL es2)
    list (APPEND EXTRA_ARGS
        -DFEATURE_opengl_dynamic=OFF
        -DFEATURE_opengles2=ON
        -DFEATURE_egl=ON
        -DFEATURE_eglfs=OFF
    )
else ()
    list (APPEND EXTRA_ARGS
        -DFEATURE_egl=OFF
    )
endif()

if (VCPKG_TARGET_IS_OSX)
    set(ALLOW_SYSTEM_LIBS ON)
else ()
    set(ALLOW_SYSTEM_LIBS OFF)
endif()

# ssl configuration
set(SSL no)
set(OPENSSL no)
set(SECURETRANSPORT OFF)
set(SCHANNEL OFF)
if (FEATURE_ssl)
    set(SSL yes)
    if (VCPKG_TARGET_IS_LINUX)
        set(OPENSSL yes)
    elseif(VCPKG_TARGET_IS_OSX)
        set(SECURETRANSPORT ON)
    elseif(VCPKG_TARGET_IS_WINDOWS)
        set(SCHANNEL ON)
    endif()
endif()

# sql configuration
set(SQLITE no)
if (FEATURE_sql)
    set(SQLITE system)
endif()

set(QT6_DIRECTORY_PREFIX "qt6/")
set(qt_plugindir ${QT6_DIRECTORY_PREFIX}plugins)
set(qt_qmldir ${QT6_DIRECTORY_PREFIX}qml)

SET(QT_DECLARATIVE OFF)

if (FEATURE_tools OR FEATURE_qml)
    set(QT_DECLARATIVE ON)
endif ()


vcpkg_configure_cmake(
    SOURCE_PATH "${SOURCE_PATH}"
    PREFER_NINJA
    OPTIONS
        -DCMAKE_OBJECT_PATH_MAX=280
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
        -DFEATURE_jasper=OFF
        -DFEATURE_dbus=OFF
        -DFEATURE_zstd=OFF
        -DFEATURE_icu=OFF
        -DFEATURE_glib=OFF
        -DFEATURE_accessibility=OFF
        -DFEATURE_brotli=OFF
        -DFEATURE_clang=OFF
        -DFEATURE_clangcpp=OFF

        -DINPUT_opengl=${OPENGL}
        -DINPUT_libjpeg=system
        -DINPUT_libpng=system
        
        -DFEATURE_system_zlib=ON
        -DFEATURE_system_pcre2=ON

        -DINPUT_freetype=${FREETYPE_HARFBUZZ}
        
        -DBUILD_qtdoc=OFF
        -DBUILD_qt3d=OFF
        -DBUILD_qtquick3d=OFF
        -DBUILD_qtshadertools=OFF
        -DBUILD_qt5compat=OFF
        -DBUILD_qtcanvas3d=OFF
        -DBUILD_qtconnectivity=OFF
        -DBUILD_qtdatavis3d=OFF
        -DBUILD_qtcharts=${FEATURE_charts}
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

        -DBUILD_qtquickcontrols=${FEATURE_qml}
        -DBUILD_qtquickcontrols2=${FEATURE_qml}
        -DBUILD_qtlottie=${FEATURE_qml}
        -DBUILD_qtquicktimeline=${FEATURE_qml}
        -DBUILD_qtwayland=${FEATURE_qml}
        -DFEATURE_qml_devtools=OFF
        
        -DBUILD_qtlocation=${FEATURE_location}
        -DFEATURE_geoservices_here=OFF
        -DFEATURE_geoservices_mapbox=OFF
        -DFEATURE_geoservices_mapboxgl=OFF

        -DINPUT_ssl=${SSL}
        -DINPUT_openssl=${OPENSSL}
        -DFEATURE_securetransport=${SECURETRANSPORT}
        -DFEATURE_schannel=${SCHANNEL}

        -DFEATURE_sql=${FEATURE_sql}
        -DINPUT_sqlite=${SQLITE}
        -DFEATURE_sql_psql=OFF
        -DFEATURE_sql_odbc=OFF
        -DFEATURE_sql_db2=OFF
        -DFEATURE_sql_ibase=OFF
        -DFEATURE_sql_mysql=OFF
        -DFEATURE_sql_oci=OFF

        -DCMAKE_FEATURE_TIFF=${FEATURE_tiff}
        -DFEATURE_system_tiff=ON

        -DBUILD_qtdeclarative=${QT_DECLARATIVE}
        -DBUILD_qtactiveqt=${FEATURE_tools}
        -DBUILD_qttools=${FEATURE_tools}
        -DBUILD_qttranslations=${FEATURE_tools}
        -DFEATURE_pdf=${FEATURE_tools}
        -DFEATURE_printsupport=${FEATURE_tools}
        -DFEATURE_linguist=${FEATURE_tools}
        -DFEATURE_qev=${FEATURE_tools}
        -DFEATURE_designer=${FEATURE_tools} # cannot be disabled, otherwise qtlinguist fails as it needs UiTools
        -DFEATURE_quick_designer=OFF
        -DFEATURE_qdbus=OFF
        -DFEATURE_kmap2qmap=OFF
        -DFEATURE_distancefieldgenerator=OFF
        -DFEATURE_pixeltool=OFF
        -DFEATURE_assistant=OFF

        ${EXTRA_ARGS}

    OPTIONS_RELEASE
        -DINPUT_debug=no
        -DFEATURE_optimize_full=ON
        
    OPTIONS_DEBUG
        -DINPUT_debug=ON
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

#fix debug plugin paths (should probably be fixed in vcpkg_fixup_pkgconfig)
file(GLOB_RECURSE DEBUG_CMAKE_TARGETS "${CURRENT_PACKAGES_DIR}/share/**/*Targets-debug.cmake")
debug_message("DEBUG_CMAKE_TARGETS:${DEBUG_CMAKE_TARGETS}")
foreach(_debug_target IN LISTS DEBUG_CMAKE_TARGETS)
    vcpkg_replace_string("${_debug_target}" "{_IMPORT_PREFIX}/${qt_plugindir}" "{_IMPORT_PREFIX}/debug/${qt_plugindir}")
    vcpkg_replace_string("${_debug_target}" "{_IMPORT_PREFIX}/${qt_qmldir}" "{_IMPORT_PREFIX}/debug/${qt_qmldir}")
endforeach()

file(GLOB BIN_FILES ${CURRENT_PACKAGES_DIR}/bin/*)
file(COPY ${BIN_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/qt6)

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

file(INSTALL ${SOURCE_PATH}/LICENSE.LGPLv3 DESTINATION  ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
