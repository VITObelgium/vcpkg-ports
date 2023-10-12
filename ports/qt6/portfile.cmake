set(MAJOR 6)
set(MINOR 6)
set(REVISION 0)
set(VERSION ${MAJOR}.${MINOR}.${REVISION})
set(PACKAGE qt-everywhere-src-${VERSION}.tar.xz)

vcpkg_find_acquire_program(PYTHON3)
vcpkg_find_acquire_program(CLANG)

get_filename_component(PYTHON_DIR ${PYTHON3} DIRECTORY)
message(STATUS "Python directory: ${PYTHON_DIR}")
vcpkg_add_to_path(${PYTHON_DIR})

get_filename_component(CLANG_BIN_DIR ${CLANG} DIRECTORY)
cmake_path(GET CLANG_BIN_DIR PARENT_PATH LLVM_DIR)
message(STATUS "LLVM directory: ${LLVM_DIR}")

vcpkg_download_distfile(ARCHIVE
    URLS "http://download.qt.io/archive/qt/${MAJOR}.${MINOR}/${VERSION}/single/${PACKAGE}"
    FILENAME "${PACKAGE}"
    SHA512 75f3e0ff25599200b525e775575f3d40f340b0bdc107a91f6d3a30bd739b5f59b13fb9d7de2e41fe19f711403afb3e9784f6a2d90e3b7a54c7077482f1bec2fb
)

vcpkg_extract_source_archive_ex(
    ARCHIVE ${ARCHIVE}
    REF ${PORT}
    OUT_SOURCE_PATH SOURCE_PATH
    PATCHES
        config_install.patch
        harfbuzz.patch
        allow_outside_prefix.patch
        angle-eglcontext.patch
        angle-findegl.patch
        angle-qtbase-direct2d-cmake.patch
        angle-qtbase-gui-cmake.patch
        angle-qtbase-gui-config.patch
        angle-qtbase-opengl-cmake.patch
        angle-qtbase-opengltester.patch
        angle-qtbase-windows-cmake.patch
        angle-qtbase-windowsintegration.patch
        angle-qtbase-windowsnativeinterface.patch
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

set(EXTRA_ARGS)
set(SECURETRANSPORT)

set (FREETYPE_HARFBUZZ system)
set (OPENGL desktop)
if (VCPKG_TARGET_IS_WINDOWS AND FEATURE_angle)
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
    list (APPEND EXTRA_ARGS
        -DFEATURE_qml_profiler=OFF
        -DFEATURE_qml_debug=OFF
        -DFEATURE_qml_delegate_model=ON
    )
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
        
        -DFEATURE_clangcpp=ON
        -DLLVM_INSTALL_DIR="${LLVM_DIR}"
        -DClang_DIR="${LLVM_DIR}/lib"

        -DVCPKG_ALLOW_SYSTEM_LIBS=${ALLOW_SYSTEM_LIBS}
        -DFEATURE_cpus=OFF
        -DFEATURE_webp=OFF
        -DFEATURE_jasper=OFF
        -DFEATURE_dbus=OFF
        -DFEATURE_zstd=OFF
        -DFEATURE_icu=OFF
        -DFEATURE_glib=OFF
        -DFEATURE_brotli=OFF
        -DFEATURE_clang=OFF
        -DFEATURE_clangcpp=OFF
        -DFEATURE_gssapi=OFF
        -DFEATURE_textmarkdownreader=OFF
        -DFEATURE_androiddeployqt=OFF

        -DINPUT_opengl=${OPENGL}
        -DINPUT_libjpeg=system
        -DINPUT_libpng=system
        
        -DFEATURE_system_zlib=ON
        -DFEATURE_system_pcre2=ON

        -DINPUT_freetype=${FREETYPE_HARFBUZZ}
        -DINPUT_harfbuzz=${FREETYPE_HARFBUZZ}
        
        -DBUILD_qtgrpc=OFF
        -DBUILD_qtdoc=OFF
        -DBUILD_qt3d=OFF
        -DBUILD_qtgraphs=OFF
        -DBUILD_qtquick3d=OFF
        -DBUILD_qtquickeffectmaker=OFF
        -DBUILD_qtquick3dphysics=OFF
        -DBUILD_qt5compat=OFF
        -DBUILD_qtcanvas3d=OFF
        -DBUILD_qtconnectivity=OFF
        -DBUILD_qtdatavis3d=OFF
        -DBUILD_qtcharts=${FEATURE_charts}
        -DBUILD_qtlanguageserver=OFF
        -DBUILD_qtmultimedia=OFF
        -DBUILD_qtpurchasing=OFF
        -DBUILD_qtpositioning=OFF
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
        -DBUILD_qthttpserver=OFF
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

        -DFEATURE_tiff=${FEATURE_tiff}
        -DFEATURE_system_tiff=${FEATURE_tiff}

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
        -DINSTALL_DOCDIR:STRING=doc/${QT6_DIRECTORY_PREFIX}
        -DINSTALL_INCLUDEDIR:STRING=include/${QT6_DIRECTORY_PREFIX}
        -DINSTALL_DESCRIPTIONSDIR:STRING=share/qt6/modules
        -DINSTALL_MKSPECSDIR:STRING=share/qt6/mkspecs
        -DINSTALL_TRANSLATIONSDIR:STRING=translations/${QT6_DIRECTORY_PREFIX}
        
    OPTIONS_DEBUG
        -DINPUT_debug=ON
        -DINSTALL_DOCDIR:STRING=../doc/${QT6_DIRECTORY_PREFIX}
        -DINSTALL_INCLUDEDIR:STRING=../include/${QT6_DIRECTORY_PREFIX}
        -DINSTALL_DESCRIPTIONSDIR:STRING=../share/Qt6/modules
        -DINSTALL_MKSPECSDIR:STRING=../share/Qt6/mkspecs
        -DINSTALL_TRANSLATIONSDIR:STRING=../translations/${QT6_DIRECTORY_PREFIX}

    MAYBE_UNUSED_VARIABLES
        BUILD_qtcanvas3d
        BUILD_qtpurchasing
        BUILD_qtquickcontrols
        BUILD_qtquickcontrols2
        BUILD_qtscript
        FEATURE_cpus
        FEATURE_geoservices_here
        FEATURE_geoservices_mapbox
        FEATURE_geoservices_mapboxgl
        FEATURE_sql_db2
        FEATURE_sql_ibase
        FEATURE_sql_mysql
        FEATURE_sql_oci
        FEATURE_sql_odbc
        FEATURE_sql_psql
        INPUT_sqlite
        VCPKG_ALLOW_SYSTEM_LIBS
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

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(GLOB_RECURSE STATIC_CMAKE_TARGETS "${CURRENT_PACKAGES_DIR}/share/Qt6Qml/QmlPlugins/*.cmake")
    foreach(_plugin_target IN LISTS STATIC_CMAKE_TARGETS)
        # restore a single get_filename_component which was remove by vcpkg_fixup_pkgconfig
        vcpkg_replace_string("${_plugin_target}" 
                                [[get_filename_component(_IMPORT_PREFIX "${CMAKE_CURRENT_LIST_FILE}" PATH)]]
                                "get_filename_component(_IMPORT_PREFIX \"\${CMAKE_CURRENT_LIST_FILE}\" PATH)\nget_filename_component(_IMPORT_PREFIX \"\${_IMPORT_PREFIX}\" PATH)")
    endforeach()
endif()

vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/share/Qt6CoreTools/Qt6CoreToolsAdditionalTargetInfo.cmake "${PACKAGE_PREFIX_DIR}/bin" "${PACKAGE_PREFIX_DIR}/tools/qt6")

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

configure_file(${CMAKE_CURRENT_LIST_DIR}/qt_debug.conf ${CURRENT_PACKAGES_DIR}/tools/qt6/qt_debug.conf)
configure_file(${CMAKE_CURRENT_LIST_DIR}/qt_release.conf ${CURRENT_PACKAGES_DIR}/tools/qt6/qt_release.conf)

file(INSTALL ${SOURCE_PATH}/LICENSE.LGPL3 DESTINATION  ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
