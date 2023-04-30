find_package(verilator HINTS $ENV{VERILATOR_ROOT} ${VERILATOR_ROOT})
if (NOT verilator_FOUND)
  message(FATAL_ERROR "Verilator was not found. Either install it, or set the VERILATOR_ROOT environment variable")
endif()

set(TARGET 1cycle)
add_executable(${TARGET} main.cc)

verilate(
  ${TARGET}
  INCLUDE_DIRS "."
  SOURCES top.v
  VERILATOR_ARGS -cc --exe --trace
)

target_link_libraries(${TARGET} PRIVATE CLI11::CLI11)
target_link_libraries(${TARGET} PRIVATE elfio::elfio)

target_include_directories(${TARGET} SYSTEM PRIVATE ${CMAKE_SOURCE_DIR}/thirdparty/CLI11/include)
target_include_directories(${TARGET} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/thirdparty/ELFIO)