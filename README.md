# pysz
A user-friendly and easy-to-maintain python wrapper for SZ3 using a python-to-c package Cython>=3.0.10.\
Pysz is fully based on SZ3(https://github.com/szcompressor/SZ3). The pure SZ3 C++ library is incorporated into pysz interface through Cython, so the compression && decompression function is running much faster than Python code.


## How to use pysz
We provided a test code in `./test/test.py` as shown below:
```python
from pysz import sz

# setup configuration of compression
dim = (101, 203869, 3)
compressor = sz.sz(*dim)
filename = 'traj_xyz.dat'
datatype = 'float'

# compression
cmpData3, cmp_ratio_2 = compressor.compress(datatype, 'sz3.config', filename)

# decompression
decmpData2 = compressor.decompress(datatype, 'sz3.config', filename + '.sz')

# verification
compressor.verify(datatype, 'sz3.config', filename, filename + '.sz')
```
The input data can either be the file path to the data file or numpy array contain the data.
## Requirements
Python>=3.10

## Installation

### Method 1. install from .whl
If you are running a linux system and using x86 or x64 CPU platform, pysz can be installed directly from a pre-compiled `.whl` file(eg. `pysz-0.0.2-cp312-cp312-linux_x86_64.whl`) located in `./dist/`. 
```bash
git clone https://github.com/JasonYang60/pysz.git
cd pysz
mv ./dist/pysz-0.0.2-cp312-cp312-linux_x86_64.whl ./
pip install pysz-0.0.2-cp312-cp312-linux_x86_64.whl
```
### Method 2. local compilation
According to your system && CPU platform, if a coresponding `.whl` is absent, you should compile pysz locally.\
First, Make sure cmake && gcc installed.\
Pysz uses python-to-c package Cython>=3.0.10, so what `setup.py` does includes downloading c++ source code from github and automatically applying cmake && make command to finish c++ code compilation.\
Then
```bash
pip install .
```

#### Generate pre-compiled .whl and .tar.gz file
To pack this project up with .whl file, some python setup tool package (`wheel`, `build`) and are required.
```bash
pip install wheel
pip install build
```
Run following code to generate `.whl` and `.tar.gz` in `./dist`:
```bash
python -m build
```
tip: there is still some issues remaining to be fixed. This command will also work:
```bash
python setup.py sdist bdist_wheel
```
### Method 3. install from Pypi
```bash
pip install pysz
```

## Launch in docker

Dockerfile is provided for testing. 
```bash
docker build --name pysz .
docker run -it --name pysz_container pysz /bin/bash
```
Then in container shell:
```bash
pip install .
cd test
python ./test.py
```

## TODO list:
to test openMP and other utils && features \
more data types to be supported