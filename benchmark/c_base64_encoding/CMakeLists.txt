cmake_minimum_required(VERSION 3.24)
set(CMAKE_C_STANDARD 99)
cmake_policy(SET CMP0135 NEW)
project(base64_benchmark VERSION 0.0.1 LANGUAGES C)

include(FetchContent)
include(GNUInstallDirs)

include(${CMAKE_CURRENT_SOURCE_DIR}/atsdk.cmake)
add_executable(${PROJECT_NAME} ${CMAKE_CURRENT_LIST_DIR}/benchmark.c)
target_link_libraries(${PROJECT_NAME} PRIVATE atchops atlogger)
