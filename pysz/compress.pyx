# distutils: language = c++
# Import the interface definitions
from pysz cimport compress
cimport cython

def compress_data(str inPath):
                #const char *cmpPath, 
                #cmp.SZ3.Config conf):
    #cdef double data[8192] # conf.num = 8192
#    cdef char *result = SZ_compress(conf, &data[0], cmpSize)
    #inStr = ""
    #with open(inPath, 'rb') as f:
    #    inStr = f.read()
    #cdef char *inBytes = nullptr
    cdef double *inBytes;
    cdef char *inPathBytes = <bytes>inPath
    readfile[double](inPathBytes, 8192, inBytes)

    cdef Config conf
    conf.loadcfg("sz.config")
    conf.blockSize = 6;
    cdef vector[size_t] dims = {128, 8, 8}
    conf.setDims(dims.begin(), dims.end())
    cdef double *outBytes = inBytes
    cdef size_t outSize = 8192
    #cdef char *outBytes = SZ_compress[double](conf, inBytes, outSize)

    #if (cmpPath == nullptr):
    #    outputFilePath += "%s.sz" + inPath
    #else:
    outputFilePath = inPath + ".sz"
    cdef char* outPathBytes = outputFilePath
    writefile[double](outPathBytes, outBytes, outSize)
    #cdef char *outCharPtr = <char*>outBytes
    #py_outBytes = <bytes> outCharPtr
    #with open(outputFilePath, 'wb') as f:
    #    f.write(py_outBytes)
    
#    write_char_array_to_file(data, 8192, outputFilePath)

# file_writer.pyx
def f1():
    # Use the defined constants
    print("SZ_FLOAT:", compress.SZ_FLOAT)
    print("initiation succeeded")
    return 0