cmake_minimum_required(VERSION 3.7)

project(zstd_vendor)

find_package(ament_cmake REQUIRED)

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
      -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
      -DCMAKE_INSTALL_PREFIX=${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}_install
      ${extra_cmake_args})

  install(
    DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}_install/
    DESTINATION ${CMAKE_INSTALL_PREFIX})
endmacro(build_zstd)



option(FORCE_BUILD_VENDOR_PKG
  "Build zstd from source, even if system-installed package is available"
  OFF
  )

#list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake/Modules")
list(INSERT CMAKE_MODULE_PATH 0 "${CMAKE_SOURCE_DIR}/cmake/Modules")
message(STATUS "CMAKE_MODULE_PATH: ${CMAKE_MODULE_PATH}")
find_package(zstd REQUIRED)
message(STATUS "zstd_INCLUDE_DIRS: ${zstd_INCLUDE_DIRS}")

ament_export_dependencies(zstd)
ament_export_libraries(zstd::zstd)
ament_export_include_directories(${zstd_INCLUDE_DIRS})  
install(DIRECTORY cmake DESTINATION share/${PROJECT_NAME})

ament_package(
  CONFIG_EXTRAS "zstd_vendor-extras.cmake"
  )
