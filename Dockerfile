FROM python:latest

# set up C/CXX compilation env
RUN apt-get update 
RUN apt-get install -y \
    build-essential \
    gcc \
    cmake \
    libcunit1-dev \
    zstd \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
# zstd is requied before building up

COPY . /home/pysz

# install required python package
RUN pip install numpy pytest cython

RUN cd /home \
    && git clone https://github.com/NeptuneYang/SZ3.git
WORKDIR /home/SZ3
# RUN mkdir build \
#     && cd build \
#     && cmake .. \
#     && make \

WORKDIR /home/pysz
