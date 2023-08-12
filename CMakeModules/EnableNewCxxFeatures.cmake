# MSVC 2022 support in 3.20
cmake_minimum_required(VERSION 3.20)

# Use C++20, but permit decay to older versions (i.e. 20 is not a hard requirement)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_EXTENSIONS OFF)
