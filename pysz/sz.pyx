# distutils: language = c++
from pysz cimport sz
from pysz cimport pyConfig
cimport cython
from cython.operator cimport dereference
import numpy as np

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

    def setDataType(this, typeStr):
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
    # pyConfig func
    def loadcfg(this, cfgPath):
        this.conf.loadcfg(cfgPath)
        print(this.conf.conf.num)

    def setDims(this, *args):
        this.conf.setDims(*args)

    def getDims(this):
        dims = []
        cdef vector[size_t] vector_dims = this.conf.conf.dims
        for i in vector_dims:
            dims.append(i)
        return tuple(dims)
    
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
            print('decompression mode... ')
            this.inBytesPtr = malloc(fileSize)
            readfile[char](inPathBytes, fileSize, <char*> this.inBytesPtr)
            this.cmpSize = fileSize
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
        writefile[char](outPathPtr, <char*> this.outBytesPtr, this.cmpSize)

    def __load_from_numpyArray(this, array):
        if not isinstance(array, np.ndarray):
            raise TypeError("Wrong params type")
        dim = array.shape
        if this.dataType == SZ_TYPE_EMPTY:
            raise TypeError("Can not read file. Data type not set")
        elif this.dataType == SZ_FLOAT:
            this.inBytesPtr = malloc(this.conf.conf.num * sizeof(float))
        elif this.dataType == SZ_DOUBLE:
            this.inBytesPtr = malloc(this.conf.conf.num * sizeof(double))
        else:
            print("Error: data type not supported")        

        this.setDims(*dim)
        this.__numpy_array_to_inBytesPtr(array)

    
    def __numpy_array_to_inBytesPtr(this, array):
        cdef int n = array.size
        flattened_array = array.flatten()
        if this.dataType == SZ_FLOAT:
            this.inBytesPtr = malloc(n * sizeof(float))
            for i in range(n):
                (<float*> this.inBytesPtr)[i] = <float> flattened_array[i]
        elif this.dataType == SZ_DOUBLE:
            this.inBytesPtr = malloc(n * sizeof(double))
            for i in range(n):
                (<double*> this.inBytesPtr)[i] = <double> flattened_array[i]
        else:
            print("Error: data type not supported") 
        print("The first 10 # in __flatened_array: ", flattened_array.flatten()[:10])
        print("The first 10 # in this.inBytesPtr: ", (<double*> this.inBytesPtr)[2])

    def __save_compressed_data_into_numpyArray(this):
        array = np.empty(this.cmpSize, dtype=np.bytes_)
        for i in range(array.size):
            array[i] = (<char*>this.outBytesPtr)[i]
        return array

    def __save_decompressed_data_into_numpyArray(this):
        array = np.empty(this.conf.conf.num)
        if this.dataType == SZ_FLOAT:
            array = array.astype(np.float32)
            for i in range(array.size):
                array[i] = (<float*> this.outBytesPtr)[i]
        elif this.dataType == SZ_DOUBLE:
            array = array.astype(np.float64)
            for i in range(array.size):
                array[i] = (<double*> this.outBytesPtr)[i]
        else:
            print("Error: data type not supported") 
        return array


    # compress func
    def __compress(this):
        print("The third # in this.inBytesPtr: ", (<double*> this.inBytesPtr)[2])
        print("The last # in this.inBytesPtr: ", (<double*> this.inBytesPtr)[this.conf.conf.num - 1])
        print("shape: ", this.getDims())
        print("num: ", this.conf.conf.num)

        if this.dataType == SZ_FLOAT:
            this.outBytesPtr = <void*> SZ_compress[float](this.conf.conf, <float*> this.inBytesPtr, this.cmpSize)
        elif this.dataType == SZ_DOUBLE:
            this.outBytesPtr = <void*> SZ_compress[double](this.conf.conf, <double*> this.inBytesPtr, this.cmpSize)
        else:
            raise TypeError("data type not supported")

        print("The third # in this.outBytesPtr: ", (<double*> this.outBytesPtr)[2])

    def compress(this, dataType, cfgPath, data):
        this.setDataType(dataType)
        this.loadcfg(cfgPath)
        cdef int dataSize = 0
        
        array = np.zeros(1)
        if isinstance(data, np.ndarray):
            print("Reading data from numpy array...")
            this.__load_from_numpyArray(data)
            this.__compress_timing()
        else:
            print("Reading data from file: ", data)
            this.readfile(data)
            this.__compress_timing()
            this.writefile(data + '.sz')

        array = this.__save_compressed_data_into_numpyArray()
        return array

    # decompress func
    def __decompress(this):
        print("The third # in this.inBytesPtr: ", (<double*> this.inBytesPtr)[2])
        print("The last # in this.inBytesPtr: ", (<double*> this.inBytesPtr)[this.conf.conf.num - 1])
        print("shape: ", this.getDims())
        print("num: ", this.conf.conf.num)
        print("N: ", this.conf.conf.N)


        if this.dataType == SZ_FLOAT:
            this.outBytesPtr = <void*> SZ_decompress[float](this.conf.conf, <char*> this.inBytesPtr, this.cmpSize)
        elif this.dataType == SZ_DOUBLE:
            this.outBytesPtr = <void*> SZ_decompress[double](this.conf.conf, <char*> this.inBytesPtr, this.cmpSize)
        else:
            raise TypeError("data type not supported")
        print("after decompression:")
        print("The third # in this.inBytesPtr: ", (<double*> this.inBytesPtr)[2])
        print("The last # in this.inBytesPtr: ", (<double*> this.inBytesPtr)[this.conf.conf.num - 1])
        print("shape: ", this.getDims())
        print("num: ", this.conf.conf.num)
        print("N: ", this.conf.conf.N)
        print("cmpSize: ", this.cmpSize)
    
    def decompress(this, dataType, cfgPath, dataPath):
        this.setDataType(dataType)
        this.loadcfg(cfgPath)
        this.readfile(dataPath, '-d')
        this.__decompress_timing()
        this.writefile(dataPath + '.out')
        array = this.__save_decompressed_data_into_numpyArray()
        print('flag1')
        array.reshape(this.getDims())
        return array

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
    def __compress_timing(this):
        this.__compress()

    @__timing_decorator
    def __decompress_timing(this):
        this.__decompress()

    def verify(this, filePath):
        free(this.inBytesPtr)
        this.readfile(filePath)
        if this.dataType == SZ_FLOAT:
            verify[float](<float*> this.inBytesPtr, <float*> this.outBytesPtr, this.conf.conf.num)
        elif this.dataType == SZ_DOUBLE:
            print(3)
            verify[double](<double*> this.inBytesPtr, <double*> this.outBytesPtr, this.conf.conf.num)
            print(4)
        else:
            raise TypeError("data type not supported")
        print("verification completed")
        # log info
        compression_ratio = this.__getFileSize(filePath) * 1.0 / this.__getFileSize(filePath + '.sz')
        print(f"compression ratio = {compression_ratio:.2f}")

    def free(this):
        free(this.inBytesPtr)
        free(this.outBytesPtr)

    def clear(this):
        this.free()
        this.dataType = SZ_TYPE_EMPTY
        this.inBytesPtr = NULL
        this.outBytesPtr = NULL
        cmpSize = 0
        this.conf = pyConfig.pyConfig()

    
