if (WIN32)
    vcpkg_add_to_path($ENV{ProgramFiles}/git/bin)
    vcpkg_add_to_path($ENV{ProgramW6432}/git/bin)
endif ()
find_package(Git)
if (NOT Git_FOUND)
    message(FATAL_ERROR "Could not find git binary")
endif ()

file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/src)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
FEATURES
    "qt5"           FEATURE_qt5
    "qt6"           FEATURE_qt6
)

if (FEATURE_qt5 EQUAL FEATURE_qt6)
    message(FATAL_ERROR "Enable either qt5 or qt6 support")
endif ()

vcpkg_from_git_mod(
    URL https://github.com/maplibre/maplibre-gl-native.git
    OUT_SOURCE_PATH SOURCE_PATH
    REF  android-v10.0.2
    HEAD_REF main
)

if (CMAKE_HOST_WIN32)
    # fix git long path issue on windows
    vcpkg_execute_required_process(
        COMMAND  ${GIT_EXECUTABLE} config core.longpaths true
        WORKING_DIRECTORY ${SOURCE_PATH}
        LOGNAME configure-long-paths-git-${TARGET_TRIPLET}
    )
endif ()

vcpkg_execute_required_process(
    COMMAND  ${GIT_EXECUTABLE} submodule update --init
    WORKING_DIRECTORY ${SOURCE_PATH}
    LOGNAME update-submodules-${TARGET_TRIPLET}
)

vcpkg_execute_required_process(
    COMMAND  ${GIT_EXECUTABLE} submodule update --init
    WORKING_DIRECTORY ${SOURCE_PATH}/vendor/mapbox-base
    LOGNAME update-mapbox-submodules-${TARGET_TRIPLET}
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        cmake-fixes-main.patch
        cmake-fixes-qt.patch
        compression-zlib.patch
        cmake-install-vendor-headers.patch
        glyph-rasterizer.patch
)
    
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DVCPKG_ALLOW_SYSTEM_LIBS=ON
        -DMBGL_WITH_RTTI=ON
        -DMBGL_WITH_QT=ON
        -DMBGL_WITH_COVERAGE=OFF
        -DMBGL_WITH_WERROR=OFF
        -DMBGL_QT_LIBRARY_ONLY=ON
        -DMBGL_QT_STATIC=ON
        ${ADDITIONAL_ARGS}
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/QMapLibreGL TARGET_PATH share/QMapLibreGL)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
