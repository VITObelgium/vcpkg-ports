include(vcpkg_common_functions)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO HowardHinnant/date
  REF v3.0.0
  SHA512 03ba0faef68e053aba888591b9350af1a043ef543825c80b1ca3f0dc0448697f56286e561f1a2a59e684680d7fc1e51fd24955c4cc222fe28db64f56037dc1aa
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
