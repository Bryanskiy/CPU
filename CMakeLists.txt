cmake_minimum_required(VERSION 3.15)

project(sim)

find_package(verilator HINTS $ENV{VERILATOR_ROOT} ${VERILATOR_ROOT})
if (NOT verilator_FOUND)
  message(FATAL_ERROR "Verilator was not found. Either install it, or set the VERILATOR_ROOT environment variable")
endif()

set(TARGET sim)
# Create a new executable target that will contain all your sources
add_executable(sim main.cc)

verilate(${TARGET}
  INCLUDE_DIRS "."
  SOURCES top.v
  VERILATOR_ARGS -cc --exe)

add_subdirectory(thirdparty)

target_include_directories(${TARGET} SYSTEM PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/thirdparty/CLI11/include)
target_include_directories(${TARGET} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/thirdparty/ELFIO)