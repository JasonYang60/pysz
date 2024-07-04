# pysz
A user-friendly and easy-to-maintain python wrapper for SZ3 using a python-to-c package Cython>=3.0.10.\
Pysz is fully based on SZ3(https://github.com/szcompressor/SZ3)and pure C++ shared library is incorporated into pysz interface through Cython, so the compression && decompression function is running much faster than Python code.\
\
Author: Jason Yang\
License: MIT

## How to use pysz
We provided a test code in `/test/test.py` as shown below:
```python
from pysz import sz

# setup configuration of compression
compressor = sz.sz(8, 8, 128)
compressor.loadcfg('sz3.config')
compressor.setType('double')
compressor.readfile('testdouble_8_8_128.dat')
compressor.set_absErrorBound(1e-3)

compressor.compress()

compressor.writefile('testdouble_8_8_128.dat.sz')

# remember always free memory from pile when finishing writing data to file
compressor.free()
```
Tips: to measure the eclipse time that the compress process uses, simpliy replace 'compressor.compress_timing()' of 'compressor.compress()'. It goes the same for '.decompress()' method.\
\
The decompression is quite similar to the compression process,
but `.readfile()` are supposed to take in an extra parameter `'-d'` right after the input file path.
```python
compressor = sz.sz(8, 8, 128)
compressor.loadcfg('sz3.config')
compressor.setType('double')

# -d: to denote swiching to decompress mode.
# (since we could not possibly expect the exact input size)
compressor.readfile('testdouble_8_8_128.dat', '-d')
compressor.set_absErrorBound(1e-3)

# compressor.decompress() is also valid except not timing 
# the decompressiong process
compressor.decompress_timing()

# you don't need to explicitly add param '-d' when writing
# into file
compressor.writefile('testdouble_8_8_128.dat.sz.out')
```

To verify if the compression && decompression function works,
use: (We only recommand you to use it in test.py, because this method haven't correctly developed and is only for debugging purpose)
```python
compressor.verify()
```
If you wanna customize your own configuration setting, besides
editing `sz3.config` in `./test/`, the python buildin interface is alse supported:
```
compressor.set_errorBoundMode('ABS')
compressor.print_errorBoundMode()
compressor.set_absErrorBound(1e-3)
```
## Dependencies
Python>=3.10\
Cython>=3.0.10\
requests
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
\

To pack this project, some python setup tool package (`wheel`, `build`) and are required.
```bash
pip install wheel
pip install build
```
Run following code to generate `.whl` and `.tar.gz` in `./dist`:
```bash
python -m build
```
### Method 3. install from Pypi
Not supported yet

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
add more config setup interfaces\
support more flexibility of data I/O beyond just from file system\
test openMP and other utils && features 
