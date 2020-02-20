include(vcpkg_common_functions)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO HowardHinnant/date
  REF 3e376be2e9b4d32c946bd83c22601e4b7a1ce421
  SHA512 9dad181f8544bfcff8c42200552b6673e537c53b34fbad11663d6435d4e5fd5a3ac6cabbb76312481c9784b237151d9ccd161bb1b8c54c563fa75073896f3cff
  HEAD_REF master
)

vcpkg_extract_source_archive(
  ${CMAKE_CURRENT_LIST_DIR}/tzdata2019a.tar.gz
  ${CURRENT_PACKAGES_DIR}/share/date/tzdata
)

set(HAS_REMOTE_API 0)
set(TZ_DB_IN_DOT OFF)
if("remote-api" IN_LIST FEATURES)
  set(HAS_REMOTE_API 1)
  set(SYSTEM_TZ_DB OFF)
else ()
  set(SYSTEM_TZ_DB ON)
  if(NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    set(TZ_DB_IN_DOT ON)
    file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/windowsZones.xml DESTINATION ${CURRENT_PACKAGES_DIR}/share/date/tzdata)
  endif ()
endif()

vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  PREFER_NINJA
  OPTIONS
    -DBUILD_TZ_LIB=ON
    -DUSE_SYSTEM_TZ_DB=${SYSTEM_TZ_DB}
    -DHAS_REMOTE_API=${HAS_REMOTE_API}
    -DUSE_TZ_DB_IN_DOT=${TZ_DB_IN_DOT}
    -DENABLE_DATE_TESTING=OFF
)

vcpkg_install_cmake()
if (VCPKG_TARGET_IS_WINDOWS)
  vcpkg_fixup_cmake_targets(CONFIG_PATH CMake TARGET_PATH share/date)
else ()
  vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/date TARGET_PATH share/date)
endif ()


vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/date RENAME copyright)
vcpkg_test_cmake(PACKAGE_NAME date)
