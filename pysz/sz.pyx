# distutils: language = c++
from pysz cimport sz
from pysz cimport pyConfig
cimport cython
from cython.operator cimport dereference

cdef class sz:
    
    # private c++ variables
    cdef void * inBytesPtr
    cdef void * outBytesPtr
    cdef size_t cmpSize
    cdef pyConfig.pyConfig conf
    cdef int dataType


    def __init__(this, *args):
        this.conf = pyConfig.pyConfig(*args)
        this.dataType = SZ_TYPE_EMPTY
        this.inBytesPtr = NULL
        this.outBytesPtr = NULL
        cmpSize = 0

    def setType(this, typeStr):
        types = {
            'float'     : SZ_FLOAT,
            'double'    : SZ_DOUBLE,
            'int32_t'   : SZ_INT32,
            'int64_t'   : SZ_INT64,
        }
        if not typeStr in types:
            raise TypeError("Error: failed to set data type. Data type not supported") 
        this.dataType = types.get(typeStr)

    # set & print config
    def set_errorBoundMode(this, EB):
        EBs = {
            'ABS'   : pyConfig.EB_ABS,
            'REL'   : pyConfig.EB_REL,
            'PSNR'  : pyConfig.EB_PSNR,
            'L2NORM': pyConfig.EB_L2NORM,
            'ABS_AND_REL'   : pyConfig.EB_ABS_AND_REL,
            'ABS_OR_REL'    : pyConfig.EB_ABS_OR_REL,
        }
        this.conf.conf.errorBoundMode = EBs.get(EB)
        if not EB in EBs:
            raise TypeError("Input Error: failed to set errorBoundMode.") 
        else:
            print("errorBoundMode set to " + EB)

    def print_errorBoundMode(this):
        print("errorBoundMode = ", this.conf.conf.errorBoundMode)

    def set_absErrorBound(this, abs):
        if not isinstance(abs, float):
            raise TypeError("Wrong params type")
        this.conf.conf.absErrorBound = abs
    def get_absErrorBound(this):
        return this.conf.conf.absErrorBound
    
    
    # pyConfig func
    def loadcfg(this, cfgPath):
        this.conf.loadcfg(cfgPath)
        print(this.conf.conf.num)

    def setDims(this, *args):
        this.conf.setDims(*args)

    cdef __getFileSize(this, filePath):
        import os
        return <size_t> os.path.getsize(filePath)
    # read and write
    def readfile(this, inPath, *args):
        # convert python string to char*
        cdef string inPathStr = <bytes> inPath.encode('utf-8')
        cdef char *inPathBytes = &inPathStr[0]
        cdef fileSize = this.__getFileSize(inPath)
        if len(args) == 1 and args[0] == '-d':
            print('decompression mode')
            #if this.dataType == SZ_FLOAT:
            #    this.cmpSize = fileSize / sizeof(float)
            #elif this.dataType == SZ_DOUBLE:
            #    this.cmpSize = fileSize / sizeof(double)
            #else:
            #    print("Error: data type not supported")
            print('cmpSize: ', this.cmpSize)

            this.inBytesPtr = malloc(fileSize)
            readfile[char](inPathBytes, fileSize, <char*> this.inBytesPtr)
        elif len(args) > 0:
            raise SyntaxError("Wrong input")
        else:
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
        if this.dataType == SZ_FLOAT:
            writefile[float](outPathPtr, <float*> this.outBytesPtr, this.cmpSize)
        elif this.dataType == SZ_DOUBLE:
            writefile[double](outPathPtr, <double*> this.outBytesPtr, this.cmpSize)
        else:
            print("Error: data type not supported")

    # compress func
    def compress(this):
        if this.dataType == SZ_FLOAT:
            this.outBytesPtr = <void*> SZ_compress[float](this.conf.conf, <float*> this.inBytesPtr, this.cmpSize)
        elif this.dataType == SZ_DOUBLE:
            this.outBytesPtr = <void*> SZ_compress[double](this.conf.conf, <double*> this.inBytesPtr, this.cmpSize)
        else:
            raise TypeError("data type not supported")

    
    # decompress func
    def decompress(this):
        if this.dataType == SZ_FLOAT:
            print("dcmpr;float: ", this.cmpSize)
            print("cmpSize:", this.cmpSize)
            # this.outBytesPtr = malloc(this.cmpSize * sizeof(float))
            print("float sz:", sizeof(float))            
            #SZ_decompress[float](this.conf.conf, <char*> this.inBytesPtr, this.cmpSize, this.outFloat)
            
            this.outBytesPtr = <void*> SZ_decompress[float](this.conf.conf, <char*> this.inBytesPtr, this.cmpSize)

        elif this.dataType == SZ_DOUBLE:
            print(this.cmpSize)
            this.outBytesPtr = <void*> SZ_decompress[double](this.conf.conf, <char*> this.inBytesPtr, this.cmpSize)
        else:
            raise TypeError("data type not supported")
        this.cmpSize = this.conf.conf.num
    
    # Utils
    def __timing_decorator(func):
        import time
        def wrapper(*args, **kwargs):
            start_time = time.time()
            result = func(*args, **kwargs)
            end_time = time.time()
            elapse_time = end_time - start_time
            print(f"{func.__name__} execution time = {elapse_time:.4f} sec")
            return result
        return wrapper

    @__timing_decorator
    def compress_timing(this):
        this.compress()

    @__timing_decorator
    def decompress_timing(this):
        this.decompress()

    def verify(this, filePath):
        free(this.inBytesPtr)
        this.readfile(filePath)
        if this.dataType == SZ_FLOAT:
            print('c')
            verify[float](<float*> this.inBytesPtr, <float*> this.outBytesPtr, this.conf.conf.num)
        elif this.dataType == SZ_DOUBLE:
            verify[double](<double*> this.inBytesPtr, <double*> this.outBytesPtr, this.conf.conf.num)
        else:
            raise TypeError("data type not supported")
        print("verification completed")
        # log info
        compression_ratio = this.__getFileSize(filePath) * 1.0 / this.__getFileSize(filePath + '.sz')
        print(f"compression ratio = {compression_ratio:.2f}")

    def free(this):
        free(this.inBytesPtr)
        free(this.outBytesPtr)

    
