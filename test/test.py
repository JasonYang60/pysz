from pysz import sz
import numpy as np

# --------------------------------------------------
#
# Prep work: set up dimensions
# --------------------------------------------------
dim = (101, 203869, 3)
compressor = sz.sz(*dim)

filename = 'traj_xyz.dat'
datatype = 'float'
# --------------------------------------------------
#
# Usage 1: File I/O
# --------------------------------------------------


# compression
cmpData3, cmp_ratio_2 = compressor.compress(datatype, 'sz3.config', filename)

# decompression
decmpData2 = compressor.decompress(datatype, 'sz3.config', filename + '.sz')


# --------------------------------------------------
#
# Usage 2: Numpy array I/O
# --------------------------------------------------

# prepare your data in numpy array format
rawData = np.fromfile(filename, dtype=np.float32)
rawData = np.reshape(rawData, dim)

# compression
cmpData1, cmp_ratio = compressor.compress(datatype, 'sz3.config', rawData)
print("cmp_ratio: ", cmp_ratio)

# decompression
cmpData2 = np.fromfile(filename + '.sz', dtype=np.uint8) 
# tips: uint8 is the only legal type for compressed data
decmpData = compressor.decompress(datatype, 'sz3.config', cmpData2)

# --------------------------------------------------
#
# Verification
# --------------------------------------------------

compressor.verify(datatype, 'sz3.config', filename, filename + '.sz.out')
# or using numpy array:
# compressor.verify(datatype, 'sz3.config', rawData, decmpData2)


print(np.array_equal(cmpData1, cmpData2))
print(np.array_equal(cmpData2, cmpData3))
print(np.array_equal(decmpData, decmpData2))
print(np.array_equal(decmpData, rawData))
print(decmpData.shape)
print(rawData.shape)

print(cmp_ratio == cmp_ratio_2)