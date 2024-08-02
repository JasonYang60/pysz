from pysz import sz

# setup configuration of compression
compressor = sz.sz(101,203869,3)
# compressor = sz.sz(101, 203869, 1)
# compressor = sz.sz(8,8,128)

filename = 'traj_xyz.dat'
# filename = 'traj_reshaped.dat'
# filename = 'testfloat_8_8_128.dat'

compressor.loadcfg('sz3.config')
compressor.setType('float')
compressor.set_errorBoundMode('ABS')
compressor.set_absErrorBound(1e-3)

compressor.readfile(filename)
compressor.compress_timing()
compressor.writefile(filename + '.sz')

# remember to free memory from pile 
# when finishing writing data to file
compressor.free()

print('decompressing...')

compressor.readfile(filename + '.sz', '-d')
compressor.decompress_timing()
compressor.writefile(filename + '.sz.out')
compressor.verify(filename)

