set(_macro__internal_dir ${CMAKE_CURRENT_LIST_DIR} CACHE INTERNAL "")

message(DEPRECATION "FindQmlPlugin module is deprecated (use find_package(Qt5QmlImportScanner REQUIRED); qt5_import_qml_plugins(<TARGET>))")

macro(vcpkg_process_prl_file_plugin Target prl_file_location Configuration)
    #message(STATUS "###### process ${Target} prl: ${prl_file_location}")
    if (NOT EXISTS "${prl_file_location}")
        MESSAGE(FATAL_ERROR "Prl file does not exist ${prl_file_location}")
    endif()

    get_filename_component(_prefix_path ${_macro__internal_dir}/../.. ABSOLUTE)

    file(STRINGS "${prl_file_location}" prl_strings REGEX "QMAKE_PRL_LIBS_FOR_CMAKE")
    string(REGEX REPLACE "QMAKE_PRL_LIBS_FOR_CMAKE *= *([^\n]*)" "\\1" static_depends ${prl_strings} )
    if (${Configuration} STREQUAL RELEASE)
        string(REPLACE "$$[QT_INSTALL_LIBS]" "${_prefix_path}/lib" static_depends "${static_depends}")
    else ()
        string(REPLACE "$$[QT_INSTALL_LIBS]" "${_prefix_path}/debug/lib" static_depends "${static_depends}")
    endif ()
    string(REPLACE "\\\\" "\\" static_depends "${static_depends}")
    string(REPLACE ";" " " static_depends "${static_depends}")
    string(STRIP "${static_depends}" static_depends)
    separate_arguments(static_depends NATIVE_COMMAND "${static_depends}")
    if (APPLE)
        string(REPLACE "-framework;" "-framework " static_depends "${static_depends}")
    elseif (MSVC)
        string(REGEX REPLACE "-L[^;]*;" "" static_depends "${static_depends}")
    endif()
    set_target_properties(${Target} PROPERTIES
        "IMPORTED_LINK_INTERFACE_LIBRARIES_${Configuration}" "${static_depends}"
    )
    
    #message(STATUS "${Target} dependencies: ${static_depends}")
endmacro()

function(find_qmlplugin)
    set (oneValueArgs NAME LIBNAME SUBDIR)
    cmake_parse_arguments(find_qmlplugin "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
    get_filename_component(_prefix_path ${_macro__internal_dir}/../.. ABSOLUTE)

    find_library(${find_qmlplugin_NAME}_LIBRARY NAMES ${find_qmlplugin_LIBNAME} HINTS ${_prefix_path}/${find_qmlplugin_SUBDIR})
    find_library(${find_qmlplugin_NAME}_LIBRARY_DEBUG NAMES ${find_qmlplugin_LIBNAME}d HINTS ${_prefix_path}/debug/${find_qmlplugin_SUBDIR} ${_prefix_path}/${find_qmlplugin_SUBDIR})

    if (${find_qmlplugin_NAME}_LIBRARY AND ${find_qmlplugin_NAME}_LIBRARY_DEBUG)
        set(${find_qmlplugin_NAME}_LIBRARY optimized ${${find_qmlplugin_NAME}_LIBRARY} debug ${${find_qmlplugin_NAME}_LIBRARY_DEBUG} PARENT_SCOPE)
        #message(STATUS "${find_qmlplugin_NAME} library: ${${find_qmlplugin_NAME}_LIBRARY}")
    endif ()

    if (NOT ${find_qmlplugin_NAME}_LIBRARY)
        message(FATAL_ERROR "${find_qmlplugin_NAME} library not found")
    endif ()

    add_library(${find_qmlplugin_NAME} STATIC IMPORTED)
    if (${find_qmlplugin_NAME}_LIBRARY)
        string(REGEX REPLACE "(.*)\.(a|lib)$"  "\\1.prl" plugin_prl_file "${${find_qmlplugin_NAME}_LIBRARY}")
        set_property(TARGET ${find_qmlplugin_NAME} APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
        set_target_properties(${find_qmlplugin_NAME} PROPERTIES IMPORTED_LOCATION_RELEASE "${${find_qmlplugin_NAME}_LIBRARY}")
        vcpkg_process_prl_file_plugin(${find_qmlplugin_NAME} ${plugin_prl_file} RELEASE)
    endif()

    if (${find_qmlplugin_NAME}_LIBRARY_DEBUG)
        string(REGEX REPLACE "(.*)\.(a|lib)$"  "\\1.prl" plugin_prl_file "${${find_qmlplugin_NAME}_LIBRARY_DEBUG}")
        set_property(TARGET ${find_qmlplugin_NAME} APPEND PROPERTY IMPORTED_CONFIGURATIONS DEBUG)
        set_target_properties(${find_qmlplugin_NAME} PROPERTIES IMPORTED_LOCATION_DEBUG "${${find_qmlplugin_NAME}_LIBRARY_DEBUG}")
        vcpkg_process_prl_file_plugin(${find_qmlplugin_NAME} ${plugin_prl_file} DEBUG)
    endif()
endfunction()
