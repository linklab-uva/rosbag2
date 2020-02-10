# - Find zstd
# Find the zstd compression library and includes
#
# zstd_INCLUDE_DIRS - where to find zstd.h, etc.
# zstd_LIBRARIES - List of libraries when using zstd.
# zstd_FOUND - True if zstd found.
if(DEFINED _VCPKG_INSTALLED_DIR)
  set(extra_hints_ ${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET})
endif(DEFINED _VCPKG_INSTALLED_DIR)

message(STATUS "Looking for ZSTD in ${extra_hints_};$ENV{ZSTD_HOME}")
find_path(zstd_INCLUDE_DIR
  NAMES zstd.h
  HINTS ${CMAKE_INSTALL_PREFIX} ${extra_hints_} ENV ZSTD_HOME
  PATH_SUFFIXES include
  )

find_library(zstd_RELEASE_LIBRARY
  NAMES zstd
  HINTS ${CMAKE_INSTALL_PREFIX} ${extra_hints_} ENV ZSTD_HOME
  PATH_SUFFIXES lib 
  )
find_library(zstd_DEBUG_LIBRARY
  NAMES zstdd
  HINTS ${CMAKE_INSTALL_PREFIX} ${extra_hints_} ENV ZSTD_HOME
  PATH_SUFFIXES lib debug/lib
  )

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(zstd DEFAULT_MSG zstd_RELEASE_LIBRARY zstd_INCLUDE_DIR)
set(zstd_LIBRARIES optimized ${zstd_RELEASE_LIBRARY} debug ${zstd_DEBUG_LIBRARY})
set(zstd_INCLUDE_DIRS ${zstd_INCLUDE_DIR})

mark_as_advanced(
  zstd_LIBRARIES
  zstd_INCLUDE_DIRS
  )

if(zstd_FOUND AND NOT (TARGET zstd::zstd))
  add_library (zstd::zstd UNKNOWN IMPORTED)
  set_target_properties(zstd::zstd
    PROPERTIES
    IMPORTED_GLOBAL TRUE
    IMPORTED_LOCATION_DEBUG ${zstd_DEBUG_LIBRARY}
    IMPORTED_LOCATION_RELEASE ${zstd_RELEASE_LIBRARY}
    INTERFACE_INCLUDE_DIRECTORIES ${zstd_INCLUDE_DIRS}
    )
endif(zstd_FOUND AND NOT (TARGET zstd::zstd))