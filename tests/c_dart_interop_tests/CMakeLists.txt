cmake_minimum_required(VERSION 3.24)
cmake_policy(SET CMP0135 NEW)

include(GNUInstallDirs)
include(FetchContent)

project(atchops_shared LANGUAGES C)
set(CMAKE_C_STANDARD 99)

set(ROOT_DIR ${CMAKE_CURRENT_LIST_DIR}/../..)
set(ATCHOPS_BUILD_TESTS OFF)
set(ATCHOPS_AS_SUBPROJECT ON)

FetchContent_Declare(
  atchops
  SOURCE_DIR
  ${ROOT_DIR}/modules/c/at_c/packages/atchops
)

FetchContent_MakeAvailable(atchops)

add_library(
  ${PROJECT_NAME}
  SHARED
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/atchops.def>
  $<TARGET_OBJECTS:atchops>
  $<TARGET_OBJECTS:atlogger>
  $<TARGET_OBJECTS:mbedcrypto>
  $<TARGET_OBJECTS:mbedx509>
  $<TARGET_OBJECTS:uuid4-static>
)

set_target_properties(
  ${PROJECT_NAME}
  PROPERTIES SOVERSION 1 OUTPUT_NAME "atchops"
)

if(WIN32)
  set_target_properties(${PROJECT_NAME} PROPERTIES LINK_FLAGS "/WHOLEARCHIVE")
elseif(APPLE)
  set_target_properties(
    ${PROJECT_NAME}
    PROPERTIES
      LINK_FLAGS "-Wl,-all_load"
      XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY "$ENV{XCODE_CODE_SIGN_IDENTITY}"
  )
else()
  set_target_properties(
    ${PROJECT_NAME}
    PROPERTIES LINK_FLAGS "-Wl,--whole-archive"
  )
endif()
