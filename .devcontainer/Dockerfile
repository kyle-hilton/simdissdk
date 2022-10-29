FROM fedora:latest

RUN yum update -y
RUN yum install gcc \
                gcc-c++ \
                cmake \
                wget \
                bzip2 \
                unzip \
                valgrind \
                gdb \
                git \
                python3-devel \
                eigen3 \
                pybind11-devel \
                GeographicLib \
                libconfig-devel \

                # simdissdk deps
                doxygen \
                freeglut-devel \
                libXinerama \
                libXrandr \
                qt5-qtbase-devel \
                qt5-qttools-devel \
                mesa-dri-drivers \

                # all the deps for simdissdk (3rd party)
                glew-devel \
                OpenSceneGraph-devel \
                osgearth-devel \
                protobuf-devel \
                swig \
                sqlite-devel \
                gdal \
                python-gdal \
                -y

ENV DISPLAY="192.168.176.1:0.0"
ENV CXX="/usr/bin/g++"
ENV SIMDIS_SDK_FILE_PATH="/usr/local"
ENV SIMDIS_FONTPATH="/fonts"

RUN cd /

# get the data needed
RUN wget https://github.com/USNavalResearchLaboratory/simdissdk/releases/download/simdissdk-1.17/SIMDIS_SDK-Data.zip
RUN unzip SIMDIS_SDK-Data.zip -d /usr/local/share
RUN chmod +777 /usr/local/share/SIMDIS_SDK-Data/*

# RUN wget https://github.com/USNavalResearchLaboratory/simdissdk/archive/refs/tags/simdissdk-1.17.zip
# RUN unzip simdissdk-1.17.zip

# get the 3rd party libs from the latest release
RUN wget https://github.com/USNavalResearchLaboratory/simdissdk/releases/download/simdissdk-1.17/SIMDIS_SDK_3rd_linux64_gcc-8.3.tbz2
RUN bzip2 -d SIMDIS_SDK_3rd_linux64_gcc-8.3.tbz2
RUN tar -xvf SIMDIS_SDK_3rd_linux64_gcc-8.3.tar

# clone the simdis source code
# RUN git clone https://github.com/kyle-hilton/simdissdk.git
# RUN git -C /simdissdk pull
# RUN git -C /simdissdk checkout sensor-sim

# put the 3rd party libs into the source code
# RUN mkdir /simdissdk/3rd
# RUN cp -r SIMDIS_SDK/3rd/linux64_gcc-8.3/ /simdissdk/3rd

# RUN cmake -S simdissdk -B simdissdk/build
# RUN make install -j16 -C simdissdk/build

# in /usr/include/osgEarth/ElevationPool:80, change private -> public
