vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO HowardHinnant/date
  REF 9ea5654c1206e19245dc21d8a2c433e090c8c3f5
  SHA512 e5d8c1da9c579fb341472d2eaa967fea2c7bad717d8786be35526092cf53ca3dbde505a116b100910702bf153c1a34c67f3f08f454d89ffaedb7d38895342da0
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
