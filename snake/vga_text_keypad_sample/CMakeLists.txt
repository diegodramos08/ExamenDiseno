# rm -rf build && mkdir build && cd build
# cmake ..
# cmake --build .

cmake_minimum_required(VERSION 3.8)
project(VGATest)

find_package(verilator HINTS $ENV{VERILATOR_ROOT} ${VERILATOR_ROOT})
if (NOT verilator_FOUND)
  message(FATAL_ERROR "Verilator was not found. Either install it, or set the VERILATOR_ROOT environment variable")
endif()

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake/")
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(SDL2 REQUIRED)

set(VERILOG_SRCDIR "${CMAKE_SOURCE_DIR}/verilog")

set(VERILOG_SOURCES "verilog/vga/DualPortVGARam.v \
                     verilog/vga/FontRom.v \
                     verilog/vga/RomColorPalette.v \
                     verilog/vga/VGATextCard.v \
                     verilog/vga/MillisCounter.v \
                     verilog/KeypadSampleFSM.v \
                     verilog/VGATest.v")

separate_arguments(VERILOG_SOURCES)

include_directories(${CMAKE_SOURCE_DIR}/cpp)
include_directories(${CMAKE_SOURCE_DIR}/cpp/sdl)
include_directories(${CMAKE_CURRENT_BINARY_DIR})
include_directories(${SDL2_INCLUDE_DIR})

# Create a new executable target that will contain all your sources
add_executable(${PROJECT_NAME}  cpp/Main.cpp
                                cpp/sdl/VGATextWindow.cpp)
                                
target_link_libraries(${PROJECT_NAME} PRIVATE ${SDL2_LIBRARIES})
target_link_libraries(${PROJECT_NAME} PRIVATE -lpthread)

# Add the Verilated circuit to the target
verilate(${PROJECT_NAME}
    TOP_MODULE "VGATest"
    PREFIX "VVGATest"
    INCLUDE_DIRS "${VERILOG_SRCDIR}"
    SOURCES ${VERILOG_SOURCES})
