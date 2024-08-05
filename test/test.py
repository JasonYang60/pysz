from pysz import sz
import numpy as np
# # setup configuration of compression
# # compressor = sz.sz(101,203869,3)
# # compressor = sz.sz(101, 203869, 1)
dim = (101, 203869, 3)

compressor = sz.sz(*dim)

# # print("size of input: ", compressor.getDims())
filename = 'traj_xyz.dat'
# # # filename = 'traj_reshaped.dat'
# filename = 'testfloat_8_8_128.dat'
# # # filename = 'testdouble_8_8_128.dat'

# prepare your data in numpy array format
data = np.fromfile(filename, dtype=np.float32)
data = np.reshape(data, dim)

array = compressor.compress('float', 'sz3.config', filename)
print("shape: ", array.shape)
compressor.free()
array = compressor.decompress('float', 'sz3.config', filename + '.sz')
compressor.verify(filename)
# # compressor.loadcfg('sz3.config')
# # compressor.setType('double')
# # # compressor.setType('float')
# # compressor.set_errorBoundMode('ABS')
# # compressor.set_absErrorBound(1e-3)

# # compressor.readfile(filename)
# # compressor.compress_timing()
# # compressor.writefile(filename + '.sz')
# # # outArray = compressor.save_into_numpyArray()

# # # print("shape: ", outArray.shape)
# # # print("The first 10 # in array: ", outArray.flatten()[:10])

# # # remember to free memory from pile 
# # # when finishing writing data to file
# # compressor.free()

# # print('decompressing...')

# # compressor.readfile(filename + '.sz', '-d')
# # compressor.decompress_timing()
# # compressor.writefile(filename + '.sz.out')
# # compressor.verify(filename)

# # # reset
# compressor.clear()

# compressor = sz.sz(*dim)



# compressor.loadcfg('sz3.config')
# compressor.setType('double')
# # compressor.setType('float')
# compressor.set_errorBoundMode('ABS')
# compressor.set_absErrorBound(1e-3)

# # compressor.load_from_numpyArray(data)
# # compressor.compress_timing()
# # cmpArray = compressor.save_into_numpyArray()
# # compressor.writefile(filename + '.sz')

# # print("shape: ", cmpArray.shape)
# # print("The first 10 # in array: ", cmpArray.flatten()[:10])

# compressor.free()

# print("decompressing...")
# compressor.readfile(filename + '.sz', '-d')
# print(1)
# compressor.decompress_timing()
# print(2)
# dcmpArray = compressor.save_decompressed_data_into_numpyArray()
# # print(b)
# # print("size of dcmpArray: ", dcmpArray.size)
# # print("The first 10 # in decompressed array: ", dcmpArray.flatten()[0])

# compressor.verify(filename)



