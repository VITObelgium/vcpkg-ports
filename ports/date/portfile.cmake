vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO HowardHinnant/date
  REF v3.0.1
  SHA512 6bdc7cba821d66e17a559250cc0ce0095808e9db81cec9e16eaa4c31abdfa705299c67b72016d9b06b302bc306d063e83a374eb00728071b83a5ad650d59034f
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
