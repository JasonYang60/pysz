# distutils: language = c++
# Import the interface definitions
from pysz cimport compress
cimport cython
from libc.stdlib cimport malloc, free
from libcpp.string cimport string

cdef compress_double(pyConfig.Config &conf, const double *inBytes):
    cdef size_t outSize
    cdef char *outBytesPtr = SZ_compress[double](conf, inBytes, outSize)
    return outBytesPtr

def compress(dataType, inPath, cmpPath, cfgPath):
    # set up configuration
    cdef pyConfig.pyConfig pyCfg = pyConfig.pyConfig()
    pyCfg.loadcfg(cfgPath)
    
    # read raw data from inPath
    cdef string inPathStr = inPath
    cdef char *inPathBytes = &inPathStr[0]
    cdef double *inBytes = <double *> malloc(pyCfg.conf.num * sizeof(double))
    print(inPathBytes)
    readfile[double](inPathBytes, pyCfg.conf.num, inBytes)

    # compression. remember to free inBytes, outBytesPtr
    cdef size_t outSize = 0
    cdef pyConfig.Config conf = pyCfg.conf
    cdef char *outBytes = SZ_compress[double](pyCfg.conf, inBytes, outSize)

    # write
    cdef double *outBytes_double = <double*> outBytes
    cdef string cmpPathStr = cmpPath
    cdef char* outPathBytes = &cmpPathStr[0]
    writefile[double](outPathBytes, outBytes_double, outSize)

    # print
    compression_ratio = pyCfg.conf.num * 1.0 * sizeof(double) / outSize
    print(f"compression ratio = {compression_ratio:.2f}")

    # free
    free(inBytes)
    free(outBytes)