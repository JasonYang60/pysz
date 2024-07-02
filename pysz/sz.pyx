# distutils: language = c++
from pysz cimport sz
from pysz cimport pyConfig
cimport cython

cdef class sz:
    
    cdef void * inBytesPtr
    cdef void * outBytesPtr
    cdef size_t outSize
    cdef pyConfig.pyConfig conf
    cdef int dataType

    def __init__(this, *args):
        this.conf = pyConfig.pyConfig(*args)
        this.dataType = SZ_TYPE_EMPTY
        this.inBytesPtr = NULL
        this.outBytesPtr = NULL
        outSize = 0


    def setType(this, typeStr):
        types = {
            'float'     : SZ_FLOAT,
            'double'    : SZ_DOUBLE,
            'int32_t'   : SZ_INT32,
            'int64_t'   : SZ_INT64,
        }
        if types.get(typeStr):
            this.dataType = types.get(typeStr)
        else:
            this.dataType = SZ_TYPE_EMPTY
            raise TypeError("Error: data type not supported") 

    # pyConfig func
    def loadcfg(this, cfgPath):
        this.conf.loadcfg(cfgPath)

    def setDims(this, *args):
        this.conf.setDims(*args)

    # read and write
    def readfile(this, inPath):
        # convert python string to char*
        cdef string inPathStr = <bytes> inPath.encode('utf-8')
        cdef char *inPathBytes = &inPathStr[0]

        this.inBytesPtr = malloc(this.conf.conf.num * sizeof(double))
        print(inPathBytes)
        readfile[double](inPathBytes, this.conf.conf.num, <double*> this.inBytesPtr)

    def writefile(this, outPath):
        # convert python string to char*
        cdef string outPathStr = <bytes> outPath.encode('utf-8')
        cdef char* outPathPtr = &outPathStr[0]
        
        writefile[double](outPathPtr, <double*> this.outBytesPtr, this.outSize)

    # compress func
    def compress(this):
        cdef char *outBytes = SZ_compress[double](this.conf.conf, <double*> this.inBytesPtr, this.outSize)
        this.outBytesPtr = <void*> outBytes

    def free(this):
        free(this.inBytesPtr)
        free(this.outBytesPtr)

    
