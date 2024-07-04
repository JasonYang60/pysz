from pysz import sz

# setup configuration of compression
compressor = sz.sz(8, 8, 128)
compressor.loadcfg('sz3.config')
compressor.setType('double')
compressor.readfile('testdouble_8_8_128.dat')
compressor.set_absErrorBound(1e-3)

compressor.compress_timing()

compressor.writefile('testdouble_8_8_128.dat.sz')
# remember to free memory from pile 
# when finishing writing data to file
compressor.free()

print('decompressing...')

compressor.readfile('testdouble_8_8_128.dat.sz', '-d')
compressor.decompress_timing()
compressor.writefile('testdouble_8_8_128.dat.sz.out')

compressor.verify()



compressor.print_errorBoundMode()
compressor.set_errorBoundMode('ABS')
