# distutils: language = c++
from pysz cimport pyConfig
cimport cython


cdef class pyConfig:
    # Hold a C++ instance which we're wrapping 

    def __init__(self, *args):
        self.conf = Config()
        cdef vector[size_t] dims = {}
        if len(args) > 0:
            for arg in args:
                if not isinstance(arg, int):
                    raise TypeError("The argument must be an integer.")
                dims.push_back(arg)
            self.conf.setDims(dims.begin(), dims.end())
            self.conf.blockSize = 128 if self.conf.N == 1 else (16 if self.conf.N == 2 else 6)
       
    
    def setDims(self, *args):
        cdef vector[size_t] dims = {}
        if len(args) > 0:
            for arg in args:
                if not isinstance(arg, int):
                    raise TypeError("The argument must be an integer.")
                dims.push_back(arg)
            self.conf.setDims(dims.begin(), dims.end())

    def loadcfg(self, cfgpath):
        cdef string cfgpathStr = <bytes> cfgpath.encode('utf-8')
        self.conf.loadcfg(cfgpathStr)
