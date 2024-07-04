FROM python:latest

# install C/CXX compilation env
RUN apt-get update 
RUN apt-get install -y \
    build-essential \
    gcc \
    cmake \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN cd /home \
    && git clone 'https://github.com/JasonYang60/pysz'

WORKDIR /home/pysz

# run:
# pip install -e .
# 
