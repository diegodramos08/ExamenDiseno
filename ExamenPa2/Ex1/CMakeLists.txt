cmake_minimum_required(VERSION 3.8)
project(exp_by_squaring)

find_package(verilator HINTS $ENV{VERILATOR_ROOT} ${VERILATOR_ROOT})
if (NOT verilator_FOUND)
  message(FATAL_ERROR "Verilator was not found. Either install it, or set the VERILATOR_ROOT environment variable")
endif()

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_executable(${PROJECT_NAME} exp_test.cpp)

# Add the Verilated circuit to the target
verilate(${PROJECT_NAME}
  INCLUDE_DIRS "."
  SOURCES Exp.v)
