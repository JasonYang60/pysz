FROM python:3.10-buster

# set up C/CXX compilation env
RUN apt-get update && apt-get install -y \
    build-essential \
    gcc \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY . /home/pysz

# install required python package
RUN pip install numpy pytest

WORKDIR /home/pysz