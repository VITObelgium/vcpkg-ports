if (WIN32)
    vcpkg_add_to_path($ENV{ProgramFiles}/git/bin)
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
    URL https://github.com/mapbox/mapbox-gl-native.git
    OUT_SOURCE_PATH SOURCE_PATH
    REF maps-v1.6.0
    HEAD_REF master
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
        iterator-include.patch
        tuple.patch
        glyph-rasterizer.patch
        msvc.patch
        qt6-support.patch
        networkslot.patch
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
        ${ADDITIONAL_ARGS}
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/FindMapboxGL.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/cmake)
file(INSTALL ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
