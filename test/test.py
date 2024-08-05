from pysz import sz
import numpy as np
# setup configuration of compression
# compressor = sz.sz(101,203869,3)
# compressor = sz.sz(101, 203869, 1)
dim = (128, 8, 8)

compressor = sz.sz(*dim)

print("size of input: ", compressor.getDims())
# filename = 'traj_xyz.dat'
# filename = 'traj_reshaped.dat'
filename = 'testdouble_8_8_128.dat'
# filename = 'testdouble_8_8_128.dat'

compressor.loadcfg('sz3.config')
compressor.setType('double')
# compressor.setType('float')
compressor.set_errorBoundMode('ABS')
compressor.set_absErrorBound(1e-3)

compressor.readfile(filename)
compressor.compress_timing()
# compressor.writefile(filename + '.sz')
outArray = compressor.save_into_numpyArray()

print("shape: ", outArray.shape)
print("The first 10 # in array: ", outArray.flatten()[:10])

# # remember to free memory from pile 
# # when finishing writing data to file
# compressor.free()

# print('decompressing...')

# compressor.readfile(filename + '.sz', '-d')
# compressor.decompress_timing()
# compressor.writefile(filename + '.sz.out')
# compressor.verify(filename)

# # reset
compressor.clear()

compressor = sz.sz(*dim)

# prepare your data in numpy array format
data = np.fromfile(filename, dtype=np.float64)
data = np.reshape(data, dim)

compressor.loadcfg('sz3.config')
compressor.setType('double')
# compressor.setType('float')
compressor.set_errorBoundMode('ABS')
compressor.set_absErrorBound(1e-3)

compressor.load_from_numpyArray(data)
compressor.compress_timing()
outArray = compressor.save_into_numpyArray()
# compressor.writefile(filename + '.sz')

compressor.free()

print("shape: ", outArray.shape)
print("The first 10 # in array: ", outArray.flatten()[:10])
