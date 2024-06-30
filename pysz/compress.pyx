# Import the interface definitions
from pysz cimport compress
cimport cython


def compress_data(str inPath):
                #const char *cmpPath, 
                #cmp.SZ3.Config conf):
    cdef double data[8192] # conf.num = 8192
#    cdef char *result = SZ_compress(conf, &data[0], cmpSize)
    inBytes = ""
    with open(inPath, 'rb') as f:
        inBytes = f.read()

    cdef char *outBytes = inBytes
    #cdef char *outBytes = SZ_compress(conf, )

    #if (cmpPath == nullptr):
    #    outputFilePath += "%s.sz" + inPath
    #else:
    outputFilePath = inPath + ".sz"
    py_outBytes = <bytes> outBytes
    with open(outputFilePath, 'wb') as f:
        f.write(py_outBytes)
    
#    write_char_array_to_file(data, 8192, outputFilePath)

# file_writer.pyx
def f1():
    # Use the defined constants
    print("SZ_FLOAT:", compress.SZ_FLOAT)
    print("initiation succeeded")
    return 0