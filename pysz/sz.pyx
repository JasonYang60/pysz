# distutils: language = c++
from pysz cimport sz
from pysz cimport pyConfig
cimport cython
# Define the macros as constants in Cython
cdef int SZ_FLOAT   = -1
cdef int SZ_DOUBLE  = 1
cdef int SZ_UINT8   = 2
cdef int SZ_INT8    = 3
cdef int SZ_UINT16  = 4
cdef int SZ_INT16   = 5
cdef int SZ_UINT32  = 6
cdef int SZ_INT32   = 7
cdef int SZ_UINT64  = 8
cdef int SZ_INT64   = 9

# To indicate that type is set incorrectly
cdef int SZ_TYPE_EMPTY = 0

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
        this.dataType = types.get(typeStr)
        if not this.dataType:
            raise TypeError("Error: failed to set data type. Data type not supported") 

    # pyConfig func
    def loadcfg(this, cfgPath):
        this.conf.loadcfg(cfgPath)
        print(this.conf.conf.num)

    def setDims(this, *args):
        this.conf.setDims(*args)

    # read and write
    def readfile(this, inPath):
        # convert python string to char*
        cdef string inPathStr = <bytes> inPath.encode('utf-8')
        cdef char *inPathBytes = &inPathStr[0]

        if this.dataType == SZ_TYPE_EMPTY:
            raise TypeError("Can not read file. Data type not set")
        elif this.dataType == SZ_FLOAT:
            this.inBytesPtr = malloc(this.conf.conf.num * sizeof(float))
            readfile[float](inPathBytes, this.conf.conf.num, <float*> this.inBytesPtr)
        elif this.dataType == SZ_DOUBLE:
            this.inBytesPtr = malloc(this.conf.conf.num * sizeof(double))
            readfile[double](inPathBytes, this.conf.conf.num, <double*> this.inBytesPtr)
        else:
            print("Error: data type not supported")

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

    
