#! /bin/bash
cd /
wget https://github.com/Kitware/CMake/releases/download/v3.24.2/cmake-3.24.2-linux-x86_64.tar.gz
tar -zxf /cmake-3.24.2-linux-x86_64.tar.gz
cp -f /cmake-3.24.2-linux-x86_64/bin/cmake /cmake-3.24.2-linux-x86_64/bin/cpack /cmake-3.24.2-linux-x86_64/bin/ctest /bin