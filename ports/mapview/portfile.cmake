include(vcpkg_common_functions)
vcpkg_from_git(
    URL https://git.vito.be/scm/marvin-geodynamix/mapview.git
    OUT_SOURCE_PATH SOURCE_PATH
    REF 0.4.2
    HEAD_REF develop
    SHA512 0
)

string(COMPARE EQUAL "static" "${VCPKG_LIBRARY_LINKAGE}" STATIC_QT)
if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_find_acquire_program(LLVM)
    get_filename_component(CLANG_EXE_PATH ${LLVM} DIRECTORY)
    set(ADDITIONAL_ARGS -DVCPKG_CLANG=ON -DVCPKG_CLANG_PATH=${CLANG_EXE_PATH})
elseif(VCPKG_TARGET_IS_OSX)
    # make sure the gl headers can be found
    set(ADDITIONAL_ARGS -DVCPKG_ALLOW_SYSTEM_LIBS=ON)
endif ()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DDEMO_APP=OFF
        -DSTATIC_QT=${STATIC_QT}
        -DMAPVIEW_INSOURCE_DEPS=OFF
        ${ADDITIONAL_ARGS}
)

vcpkg_install_cmake()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/mapview")
vcpkg_copy_pdbs()
file(WRITE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright "Copyright VITO NV\n")
