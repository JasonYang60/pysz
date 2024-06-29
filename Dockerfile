FROM python:3.10-buster

# set up C/CXX compilation env
RUN apt-get update 
RUN apt-get install -y \
    build-essential \
    gcc \
    cmake \
    libcunit1-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY . /home/pysz

# install required python package
RUN pip install numpy pytest

# set up SZ
RUN cd /home \
    && git clone https://github.com/NeptuneYang/SZ.git
WORKDIR /home/SZ
    # enable example & test in CMakeLists.txt
RUN sed -i 's/BUILD_SZ_EXAMPLES "build sz example" OFF/BUILD_SZ_EXAMPLES "build sz example" ON/' CMakeLists.txt \
    && sed -i.bak 's/BUILD_TESTS "build test cases" OFF/BUILD_TESTS "build test cases" ON/' CMakeLists.txt 
RUN mkdir build \
    && cd build \
    && cmake .. \
    && make \
    && ctest

WORKDIR /home/pysz