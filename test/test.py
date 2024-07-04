from pysz import sz

compressor = sz.sz(8, 8, 128)
compressor.loadcfg('sz3.config')
compressor.setType('double')
compressor.readfile('testdouble_8_8_128.dat')
compressor.set_absErrorBound(1e-3)
compressor.compress_timing()
compressor.writefile('testdouble_8_8_128.dat.sz')
compressor.free()

print('decompress stage:')

compressor.readfile('testdouble_8_8_128.dat.sz', '-d')
compressor.decompress_timing()

compressor.writefile('testdouble_8_8_128.dat.sz.out')

compressor.verify()

compressor.print_errorBoundMode()
compressor.set_errorBoundMode('ABS')
