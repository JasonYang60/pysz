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

    def compress(this, dataType, cfgPath, data):
        """
        Compresses data using the specified configuration and data type.

        Parameters:
        -----------
        this : object
            The instance of the class containing this method. It is typically used to access class attributes or methods.
        
        dataType : str
            The data type of the input data to be compressed. It can either be 'float' or 'double'.
        
        cfgPath : str
            The file path to the configuration file used for compression. This file contains the necessary parameters and settings for the compression algorithm.
        
        data : str or numpy.ndarray
            The data to be compressed. This can either be a file path (str) to the data file or a numpy array containing the data.
        
        Returns:
        --------
        compressed_data : numpy.ndarray
            The compressed data as a numpy array of dtype 'int8'. This represents the binary data after compression.
        
        compression_ratio : float
            The compression ratio, which is the ratio of the original data size to the compressed data size.

        tips: if the input data type is a file path to the raw data, then a compressed file named after '.sz' would be generated.

        """
        this.__setDataType(dataType)
        this.__loadcfg(cfgPath)        
        array = np.zeros(1)
        rawSize = 0
        if isinstance(data, np.ndarray):
            print("Loading data from numpy array...")
            rawSize = data.nbytes
            this.__load_from_numpyArray(data)
            this.__compress_timing()
        else:
            print("Reading data from file: " + data)
            rawSize = this.__getFileSize(data)
            this.__readfile(data)
            this.__compress_timing()
            this.__writefile(data + '.sz')
        array = this.__save_compressed_data_into_numpyArray()
        ratio = rawSize * 1.0 / this.cmpSize
        this.clear()
        return array, ratio

    def decompress(this, dataType, cfgPath, data):
        """
        Decompresses data using the specified configuration and data type.

        Parameters:
        -----------
        this : object
            The instance of the class containing this method. It is typically used to access class attributes or methods.
        
        dataType : str
            The data type of the decompressed data. It can either be 'float' or 'double'.
        
        cfgPath : str
            The file path to the configuration file used for decompression. This file contains the necessary parameters and settings for the decompression algorithm.
        
        data : numpy.ndarray
            The compressed data to be decompressed. This can either be a file path (str) to the data file or a numpy array of dtype 'int8' representing the binary data after compression.
        
        Returns:
        --------
        decompressed_data : numpy.ndarray
            The decompressed data as a numpy array with the specified data type ('float' or 'double').
        
        """
        this.__setDataType(dataType)
        this.__loadcfg(cfgPath)
        array = np.zeros(1)
        cdef size_t cmpSize = 0
        if isinstance(data, np.ndarray):
            print("Loading data from numpy array...")
            this.__load_from_numpyArray(data, '-d')
            this.__decompress_timing()
        else:
            this.__readfile(data, '-d')
            this.__decompress_timing()
            cmpSize = this.cmpSize
            if this.dataType == SZ_FLOAT:
                this.cmpSize = this.conf.conf.num * sizeof(float)
            elif this.dataType == SZ_DOUBLE:
                this.cmpSize = this.conf.conf.num * sizeof(double)
            elif this.dataType == SZ_INT32:
                this.cmpSize = this.conf.conf.num * sizeof(int32_t)
            else:
                raise TypeError("Data type not supported")
            this.__writefile(data + '.out')
            this.cmpSize = cmpSize
        
        array = this.__save_decompressed_data_into_numpyArray()
        array = array.reshape(this.getDims())
        this.clear()
        return array

    def verify(this, dataType, cfgPath, rawData, decData):
        """
        Verifies the integrity of compressed data by comparing it to the original data.

        Parameters:
        -----------
        this : object
            The instance of the class containing this method. It is typically used to access class attributes or methods.
        
        dataType : str
            The data type of the original and decompressed data. It can either be 'float' or 'double'.
        
        cfgPath : str
            The file path to the configuration file used for compression and decompression. This file contains the necessary parameters and settings for the algorithms.
        
        rawData : numpy.ndarray
            The original data to before compression. This can either be a file path (str) to the data file or a numpy array of dtype 'int8' representing the binary data after compression.

        cmpData : numpy.ndarray
            The decompressed data to be verified, as a numpy array with the same shape and data type as `rawData`. This can either be a file path (str) to the data file or a numpy array of dtype 'int8' representing the binary data after compression.

        Returns:
        --------
        None
            This function does not return any value. It performs the verification process and may raise an error or log a message if the data does not match.
        """
        print("Verifying... ")
        this.__setDataType(dataType)
        this.__loadcfg(cfgPath)
        rawSZ = 0
        decSZ = 0
        if isinstance(decData, np.ndarray):
            print("Loading data from numpy array...")
            this.__load_from_numpyArray(decData)
            decSZ = decData.nbytes
        else:
            print("Reading data from file: ", decData)
            this.__readfile(decData)
            decSZ = this.__getFileSize(decData)

        this.outBytesPtr = this.inBytesPtr
        this.inBytesPtr = NULL
        if isinstance(rawData, np.ndarray):
            print("Loading data from numpy array...")
            this.__load_from_numpyArray(rawData)
            rawSZ = rawData.nbytes
        else:
            print("Reading data from file: ", rawData)
            this.__readfile(rawData)
            rawSZ = this.__getFileSize(rawData)

        if this.dataType == SZ_FLOAT:
            verify[float](<float*> this.inBytesPtr, <float*> this.outBytesPtr, this.conf.conf.num)
        elif this.dataType == SZ_DOUBLE:
            verify[double](<double*> this.inBytesPtr, <double*> this.outBytesPtr, this.conf.conf.num)
        elif this.dataType == SZ_INT32:
            verify[int32_t](<int32_t*> this.inBytesPtr, <int32_t*> this.outBytesPtr, this.conf.conf.num)
        else:
            raise TypeError("Data type not supported")
        print("Verification completed.")
        

    def clear(this):
        this.conf = pyConfig.pyConfig(*this.getDims())
        this.__free()
        this.dataType = SZ_TYPE_EMPTY
        this.inBytesPtr = NULL
        this.outBytesPtr = NULL
        this.cmpSize = 0
    
    def __setDataType(this, typeStr):
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
    def __loadcfg(this, cfgPath):
        this.conf.loadcfg(cfgPath)
        print("The total elements of raw data is ", this.conf.conf.num)

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
    def __readfile(this, inPath, *args):
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
            elif this.dataType == SZ_INT32:
                this.inBytesPtr = malloc(this.conf.conf.num * sizeof(int32_t))
                readfile[int32_t](inPathBytes, this.conf.conf.num, <int32_t*> this.inBytesPtr)
            else:
                print("Error: data type not supported")

    def __writefile(this, outPath):
        # convert python string to char*
        cdef string outPathStr = <bytes> outPath.encode('utf-8')
        cdef char* outPathPtr = &outPathStr[0]
        writefile[char](outPathPtr, <char*> this.outBytesPtr, this.cmpSize)

    def __load_from_numpyArray(this, array, *args):
        if not isinstance(array, np.ndarray):
            raise TypeError("Wrong params type")

        if len(args) == 1 and args[0] == '-d':
            this.inBytesPtr = malloc(array.size)
            for i in range(array.size):
                (<int8_t*>this.inBytesPtr)[i] = array[i]
            this.cmpSize = array.size
            return
        elif len(args) > 0:
            raise SyntaxError("Wrong input")

        if this.dataType == SZ_TYPE_EMPTY:
            raise TypeError("Can not read file. Data type not set")
        elif this.dataType == SZ_FLOAT:
            this.inBytesPtr = malloc(this.conf.conf.num * sizeof(float))
        elif this.dataType == SZ_DOUBLE:
            this.inBytesPtr = malloc(this.conf.conf.num * sizeof(double))
        elif this.dataType == SZ_INT32:
            this.inBytesPtr = malloc(this.conf.conf.num * sizeof(int32_t))
        else:
            print("Error: data type not supported")        

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
        elif this.dataType == SZ_INT32:
            this.inBytesPtr = malloc(n * sizeof(int32_t))
            for i in range(n):
                (<int32_t*> this.inBytesPtr)[i] = <int32_t> flattened_array[i]
        else:
            print("Error: data type not supported") 

    def __save_compressed_data_into_numpyArray(this):
        array = np.empty(this.cmpSize, dtype=np.int8)
        for i in range(array.size):
            array[i] = (<int8_t*>this.outBytesPtr)[i]
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
        elif this.dataType == SZ_INT32:
            array = array.astype(np.int32)
            for i in range(array.size):
                array[i] = (<int32_t*> this.outBytesPtr)[i]
        else:
            print("Error: data type not supported") 
        return array


    # compress func
    def __compress(this):
        if this.dataType == SZ_FLOAT:
            this.outBytesPtr = <void*> SZ_compress[float](this.conf.conf, <float*> this.inBytesPtr, this.cmpSize)
        elif this.dataType == SZ_DOUBLE:
            this.outBytesPtr = <void*> SZ_compress[double](this.conf.conf, <double*> this.inBytesPtr, this.cmpSize)
        elif this.dataType == SZ_INT32:
            this.outBytesPtr = <void*> SZ_compress[int32_t](this.conf.conf, <int32_t*> this.inBytesPtr, this.cmpSize)
        else:
            raise TypeError("data type not supported")


    # decompress func
    def __decompress(this):
        if this.dataType == SZ_FLOAT:
            this.outBytesPtr = <void*> SZ_decompress[float](this.conf.conf, <char*> this.inBytesPtr, this.cmpSize)
        elif this.dataType == SZ_DOUBLE:
            this.outBytesPtr = <void*> SZ_decompress[double](this.conf.conf, <char*> this.inBytesPtr, this.cmpSize)
        elif this.dataType == SZ_INT32:
            this.outBytesPtr = <void*> SZ_decompress[int32_t](this.conf.conf, <char*> this.inBytesPtr, this.cmpSize)
        else:
            raise TypeError("data type not supported")
    
    

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

    def __free(this):
        free(this.inBytesPtr)
        free(this.outBytesPtr)
    
