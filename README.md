# pysz
Author: Jason Yang
A user-friendly and easy-to-maintain python wrapper for SZ3 using a python-to-c package Cython>=3.0.10.
Pysz is fully based on SZ3(url:https://github.com/szcompressor/SZ3). Pure C++ shared library is incorporated into pysz interface through Cython, so the compression && decompression procedure is running way more faster than Python code.

## Usage
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
Tips: to measure the eclipse time that the compress process uses, simpliy replace 'compressor.compress_timing()' of 'compressor.compress()'. It goes the same for '.decompress()' method.

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
Python>=3.10

## Installation

### Method 1. install through pre-compiled .whl file
```bash
pip install .
```
### Method 2. local compilation
Pysz uses python-to-c package Cython>=3.0.10 
```bash
pip install -e .
```
### Method 3. install from Pypi
Not supported yet

## Launch in docker

Dockfile is provided for testing. 
```bash
docker build --name pysz .
docker run -it --name pysz_container pysz /bin/bash
```
Then
```bash
pip install .
cd test
python ./test.py
```

TODO:
add more config setup interfaces
add support more flexibility in dealing with data beyond just input&&output from file
test openMP and other features 
