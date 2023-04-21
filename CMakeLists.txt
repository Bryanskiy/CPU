cmake_minimum_required(VERSION 3.15)

project(sim)

find_package(verilator HINTS $ENV{VERILATOR_ROOT} ${VERILATOR_ROOT})
if (NOT verilator_FOUND)
  message(FATAL_ERROR "Verilator was not found. Either install it, or set the VERILATOR_ROOT environment variable")
endif()

# Create a new executable target that will contain all your sources
add_executable(sim main.cc)

verilate(sim
  INCLUDE_DIRS "."
  SOURCES cpu.v
  VERILATOR_ARGS -cc --exe)
