cmake_minimum_required(VERSION 3.7)

project(zstd_vendor)

find_package(ament_cmake REQUIRED)

option(FORCE_BUILD_VENDOR_PKG
  "Build zstd from source, even if system-installed package is available"
  OFF)

if(NOT FORCE_BUILD_VENDOR_PKG)
  find_package(zstd QUIET)
endif()

macro(build_zstd)
  set(extra_cmake_args)

  if(DEFINED CMAKE_BUILD_TYPE)
    list(APPEND extra_cmake_args -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE})
  endif()

  if(DEFINED CMAKE_TOOLCHAIN_FILE)
    list(APPEND extra_cmake_args "-DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE}")
  else()
    list(APPEND extra_cmake_args "-DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}")
  endif()
  list(APPEND extra_cmake_args "-DCMAKE_CXX_FLAGS=${CMAKE_CXX_FLAGS}")

  include(ExternalProject)
  # The CMakeLists.txt file for zstd is in a subdirectory.
  # We need to configure the CMake command to build from there instead.
  ExternalProject_Add(zstd-1.4.4
    URL https://github.com/facebook/zstd/archive/v1.4.4.zip
    URL_MD5 3a5c3a535280b7f4dfdbd739fcc7173f
    TIMEOUT 60
    SOURCE_SUBDIR build/cmake
    CMAKE_ARGS
      -DCMAKE_INSTALL_PREFIX=${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}_install
      -DZSTD_BUILD_STATIC=OFF
      -DZSTD_BUILD_SHARED=ON
      -DZSTD_BUILD_PROGRAMS=OFF
      ${extra_cmake_args})

  install(
    DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}_install/
    DESTINATION ${CMAKE_INSTALL_PREFIX})
endmacro()
set(zstd_FOUND (${zstd_FOUND} OR (TARGET libzstd)))
if (NOT zstd_FOUND)# OR "${zstd_VERSION}" VERSION_LESS 1.4.4)
  build_zstd()
  install(DIRECTORY cmake DESTINATION share/${PROJECT_NAME})
  ament_package(CONFIG_EXTRAS zstd_vendor-extras.cmake)
elseif(TARGET libzstd)
  add_library(${PROJECT_NAME}_target INTERFACE)
  target_link_libraries(${PROJECT_NAME}_target INTERFACE libzstd)
  install(TARGETS ${PROJECT_NAME}_target EXPORT ${PROJECT_NAME}_target_export)
  ament_export_targets(${PROJECT_NAME}_target_export)
  ament_export_dependencies(zstd)
  ament_package()
else()
  message(FATAL_ERROR "zstd was found, but did not define the imported target libzstd")  
endif()


