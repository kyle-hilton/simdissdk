# Setup osgEarth library
# Setting the OSGEARTH_DIR environment variable will allow use of a custom built library

# Cannot locate osgEarth without OSG due to requirement on knowing OSG version
if(NOT OSG_FOUND)
    return()
endif()

set(LIBRARYNAME OSGEARTH)
set(VSI_OSGEARTH_VERSION OSG-${OSG_VERSION})
set(OSGEARTH_INSTALL_COMPONENT ThirdPartyLibs)
# Install if INSTALL_THIRDPARTY_LIBRARIES is undefined, or if it is set to true
set(OSGEARTH_SHOULD_INSTALL FALSE)
if(NOT DEFINED INSTALL_THIRDPARTY_LIBRARIES OR INSTALL_THIRDPARTY_LIBRARIES)
    set(OSGEARTH_SHOULD_INSTALL TRUE)
endif()

# Setup search paths
initialize_ENV(${LIBRARYNAME}_DIR)
set(INCLUDE_DIRS
    "/usr/include"
    $ENV{${LIBRARYNAME}_DIR}/include
    ${THIRD_DIR}/osgEarth/${VSI_OSGEARTH_VERSION}/include
)
set(LIB_DIRS
    "/usr/lib64"
    $ENV{${LIBRARYNAME}_DIR}
    ${THIRD_DIR}/osgEarth/${VSI_OSGEARTH_VERSION}
)

# Configure the core osgEarth library
find_path(${LIBRARYNAME}_LIBRARY_INCLUDE_PATH NAME osgEarth/Version PATHS ${INCLUDE_DIRS} NO_DEFAULT_PATH)
find_library(${LIBRARYNAME}_LIBRARY_DEBUG_NAME NAMES osgEarthd PATHS ${LIB_DIRS} PATH_SUFFIXES lib lib64 NO_DEFAULT_PATH)
find_library(${LIBRARYNAME}_LIBRARY_RELEASE_NAME NAMES osgEarth PATHS ${LIB_DIRS} PATH_SUFFIXES lib lib64 NO_DEFAULT_PATH)
message(STATUS "Found OsgEarth INC: ${${LIBRARYNAME}_LIBRARY_INCLUDE_PATH}")
message(STATUS "Found OsgEarth DBG: ${${LIBRARYNAME}_LIBRARY_DEBUG_NAME}")
message(STATUS "Found OsgEarth REL: ${${LIBRARYNAME}_LIBRARY_RELEASE_NAME}")


# MSVC requires -Zc:__cplusplus due to weejobs.h testing the value in header
if(MSVC)
    list(APPEND ${LIBRARYNAME}_COMPILE_OPTIONS "-Zc:__cplusplus")
endif()

if(NOT ${LIBRARYNAME}_LIBRARY_RELEASE_NAME)
    mark_as_advanced(CLEAR ${LIBRARYNAME}_LIBRARY_INCLUDE_PATH ${LIBRARYNAME}_LIBRARY_DEBUG_NAME ${LIBRARYNAME}_LIBRARY_RELEASE_NAME)
    return()
endif()
mark_as_advanced(FORCE ${LIBRARYNAME}_LIBRARY_INCLUDE_PATH ${LIBRARYNAME}_LIBRARY_DEBUG_NAME ${LIBRARYNAME}_LIBRARY_RELEASE_NAME)

# Configure compile and link flags for osgEarth
if(TARGET GDAL)
    list(APPEND ${LIBRARYNAME}_LINK_LIBRARIES GDAL)
endif()
if(TARGET GEOS_C)
    list(APPEND ${LIBRARYNAME}_LINK_LIBRARIES GEOS_C)
endif()
if(EXISTS "${${LIBRARYNAME}_LIBRARY_INCLUDE_PATH}/osgEarthDrivers/sky_silverlining/SilverLiningOptions")
    list(APPEND ${LIBRARYNAME}_COMPILE_DEFINITIONS HAVE_OSGEARTH_SILVERLINING)
    set(HAVE_OSGEARTH_SILVERLINING TRUE)
    set(OSGEARTH_SILVERLINING_SUPPORT PLUGIN)
elseif(EXISTS "${${LIBRARYNAME}_LIBRARY_INCLUDE_PATH}/osgEarthSilverLining/SilverLiningOptions")
    list(APPEND ${LIBRARYNAME}_COMPILE_DEFINITIONS HAVE_OSGEARTH_SILVERLINING)
    set(HAVE_OSGEARTH_SILVERLINING TRUE)
    set(OSGEARTH_SILVERLINING_SUPPORT NODEKIT)
    list(APPEND SUBLIBRARY_NAMES SilverLining)
endif()

if(EXISTS "${${LIBRARYNAME}_LIBRARY_INCLUDE_PATH}/osgEarthTriton/TritonLayer")
    list(APPEND ${LIBRARYNAME}_COMPILE_DEFINITIONS HAVE_OSGEARTH_TRITON)
    set(HAVE_OSGEARTH_TRITON TRUE)
    set(OSGEARTH_TRITON_SUPPORT NODEKIT)
    list(APPEND SUBLIBRARY_NAMES Triton)
elseif(EXISTS "${${LIBRARYNAME}_LIBRARY_INCLUDE_PATH}/osgEarthDrivers/ocean_triton/TritonOptions")
    list(APPEND ${LIBRARYNAME}_COMPILE_DEFINITIONS HAVE_OSGEARTH_TRITON)
    set(HAVE_OSGEARTH_TRITON TRUE)
    set(OSGEARTH_TRITON_SUPPORT PLUGIN)
elseif(EXISTS "${${LIBRARYNAME}_LIBRARY_INCLUDE_PATH}/osgEarthTriton/TritonOptions")
    list(APPEND ${LIBRARYNAME}_COMPILE_DEFINITIONS HAVE_OSGEARTH_TRITON)
    set(HAVE_OSGEARTH_TRITON TRUE)
    set(OSGEARTH_TRITON_SUPPORT NODEKIT)
    list(APPEND SUBLIBRARY_NAMES Triton)
endif()

# osgEarthImGui added in osgEarth SOVERSION 159
if(EXISTS "${${LIBRARYNAME}_LIBRARY_INCLUDE_PATH}/osgEarthImGui/ImGuiPanel")
    set(HAVE_OSGEARTH_IMGUI_NODEKIT TRUE)
    list(APPEND SUBLIBRARY_NAMES ImGui)
endif()

# Internal macro to import osgEarth libraries.  NAME can be empty string, Util, Symbology, etc.
macro(import_osgearth_lib NAMEVAL)
    if("${NAMEVAL}" STREQUAL "")
        set(LIBRARYNAME OSGEARTH)
    else()
        string(TOUPPER OSGEARTH_${NAMEVAL} LIBRARYNAME)
    endif()
    find_library(${LIBRARYNAME}_LIBRARY_DEBUG_NAME NAMES osgEarth${NAMEVAL}d PATHS ${LIB_DIRS} PATH_SUFFIXES lib lib64 NO_DEFAULT_PATH)
    find_library(${LIBRARYNAME}_LIBRARY_RELEASE_NAME NAMES osgEarth${NAMEVAL} PATHS ${LIB_DIRS} PATH_SUFFIXES lib lib64 NO_DEFAULT_PATH)
    list(APPEND ${LIBRARYNAME}_LINK_LIBRARIES OSGVIEWER OSGGA OPENTHREADS)

    # Determine whether we found the library correctly
    if(NOT ${LIBRARYNAME}_LIBRARY_RELEASE_NAME)
        set(${LIBRARYNAME}_FOUND FALSE)
        mark_as_advanced(CLEAR ${LIBRARYNAME}_LIBRARY_DEBUG_NAME ${LIBRARYNAME}_LIBRARY_RELEASE_NAME)
        break()
    endif()
    mark_as_advanced(FORCE ${LIBRARYNAME}_LIBRARY_DEBUG_NAME ${LIBRARYNAME}_LIBRARY_RELEASE_NAME)
    set(${LIBRARYNAME}_FOUND TRUE)

    # Set the release path, include path, and link libraries
    add_library(${LIBRARYNAME} SHARED IMPORTED)
    set_target_properties(${LIBRARYNAME} PROPERTIES
        IMPORTED_IMPLIB "${${LIBRARYNAME}_LIBRARY_RELEASE_NAME}"
        INTERFACE_INCLUDE_DIRECTORIES "${${LIBRARYNAME}_LIBRARY_INCLUDE_PATH}"
        INTERFACE_COMPILE_OPTIONS "${${LIBRARYNAME}_COMPILE_OPTIONS}"
        INTERFACE_COMPILE_DEFINITIONS "${${LIBRARYNAME}_COMPILE_DEFINITIONS}"
        INTERFACE_LINK_LIBRARIES "${${LIBRARYNAME}_LINK_LIBRARIES}"
    )
    if(${LIBRARYNAME}_LIBRARY_DEBUG_NAME)
        set_target_properties(${LIBRARYNAME} PROPERTIES
            IMPORTED_IMPLIB_DEBUG "${${LIBRARYNAME}_LIBRARY_DEBUG_NAME}"
        )
    endif()
    vsi_set_imported_locations_from_implibs(${LIBRARYNAME})
    if(OSGEARTH_SHOULD_INSTALL)
        vsi_install_target(${LIBRARYNAME} ${OSGEARTH_INSTALL_COMPONENT})
    endif()
endmacro()

import_osgearth_lib("")
foreach(SUBNAME ${SUBLIBRARY_NAMES})
    import_osgearth_lib(${SUBNAME})
endforeach()

# Plug-ins are found in lib, unless on Windows
set(OS_PLUGIN_SUBDIR "lib${LIBDIRSUFFIX}")
if(WIN32)
    set(OS_PLUGIN_SUBDIR "bin")
endif()
set(OS_PLUGIN_SUBDIR "${OS_PLUGIN_SUBDIR}/osgPlugins-${OSG_VERSION}")

# Install osgEarth plugins
set(PLUGIN_DIRS
    "/usr/lib64/osgPlugins-3.6.5"
    $ENV{OSGEARTH_DIR}
    ${THIRD_DIR}/osgEarth/${VSI_OSGEARTH_VERSION}
)

# Find the plugin location
find_path(OSGEARTH_PLUGIN_PATH
    NAMES osgdb_earth.dll osgdb_earth.so
    PATHS ${PLUGIN_DIRS}
    PATH_SUFFIXES
        bin/osgPlugins-${OSG_VERSION}
        lib/osgPlugins-${OSG_VERSION}
        lib64/osgPlugins-${OSG_VERSION}
    NO_DEFAULT_PATH
)
find_path(OSGEARTH_PLUGIN_PATH NAMES osgdb_earth.dll osgdb_earth.so PATHS ${PLUGIN_DIRS} NO_DEFAULT_PATH)

message(STATUS "Found OsgEarth Plugin LIB: ${OSGEARTH_PLUGIN_PATH}")
if(OSGEARTH_PLUGIN_PATH)
    mark_as_advanced(FORCE OSGEARTH_PLUGIN_PATH)
else()
    mark_as_advanced(CLEAR OSGEARTH_PLUGIN_PATH)
    message(WARNING "osgEarth Plug-in Path not found. Will result in improper installation.")
endif()

# Put the plugin location in the library list for 32 to 64 but Linux conversion
# so it is properly updated when a 32/64 bit configuration change is made
list(APPEND LIBRARY_LIST "OSGEARTH_PLUGIN_PATH")

# Select installation location
if(WIN32)
    set(OSGEARTH_PLUGIN_INSTALL_DIR ${INSTALLSETTINGS_RUNTIME_DIR})
else()
    set(OSGEARTH_PLUGIN_INSTALL_DIR ${INSTALLSETTINGS_LIBRARY_DIR})
endif()

# Determine which files to install based on Debug or Release Build Type
if(WIN32)
    set(DEBUG_INSTALL_PATTERN "osgdb_.+d\\.dll")
    set(RELEASE_INSTALL_PATTERN "osgdb_.+[^d]\\.dll")
else()
    set(DEBUG_INSTALL_PATTERN "osgdb_.+d\\.so")
    set(RELEASE_INSTALL_PATTERN "osgdb_.+[^d]\\.so")
endif()

# Set the full install path to the plugin directory
set(OSGEARTH_PLUGIN_INSTALL_DIR ${OSGEARTH_PLUGIN_INSTALL_DIR}/osgPlugins-${OSG_VERSION})

if(OSGEARTH_SHOULD_INSTALL)
    # Note that "*billboard.*" is a release pattern, not debug
    install(DIRECTORY ${OSGEARTH_PLUGIN_PATH}/
        DESTINATION ${OSGEARTH_PLUGIN_INSTALL_DIR}
        CONFIGURATIONS "Debug"
        COMPONENT ${OSGEARTH_INSTALL_COMPONENT}
        FILES_MATCHING
            REGEX ${DEBUG_INSTALL_PATTERN}
            PATTERN "*billboard.*" EXCLUDE)

    # SIM-13848: Install release DLLs on Linux if debug not found
    set(CONFIG "Release")
    if(UNIX AND NOT EXISTS "${OSG_PLUGIN_PATH}/osgdb_rotd.so")
        set(CONFIG)
    endif()

    # Note that "*billboard.*" is a release pattern and needs inclusion
    install(DIRECTORY ${OSGEARTH_PLUGIN_PATH}/
        DESTINATION ${OSGEARTH_PLUGIN_INSTALL_DIR}
        CONFIGURATIONS ${CONFIG}
        COMPONENT ${OSGEARTH_INSTALL_COMPONENT}
        FILES_MATCHING
            REGEX ${RELEASE_INSTALL_PATTERN}
            PATTERN "*billboard.*")
endif()
