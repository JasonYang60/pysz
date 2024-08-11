from libcpp.string cimport string
from libc.stdlib cimport malloc, free
from libcpp.vector cimport vector
from pysz cimport pyConfig
from libc.stdint cimport int32_t, int8_t

cdef enum SZ_TYPE:
    SZ_TYPE_EMPTY
    SZ_FLOAT
    SZ_DOUBLE
    SZ_UINT8
    SZ_INT8
    SZ_UINT16
    SZ_INT16
    SZ_UINT32
    SZ_INT32
    SZ_UINT64
    SZ_INT64

cdef extern from "SZ3/utils/FileUtil.hpp" namespace "SZ3":
    void readfile[Type](const char *file, const size_t num, Type *data)
    void writefile[Type](const char *file, Type *data, size_t num_elements)

cdef extern from "SZ3/api/sz.hpp":
    char* SZ_compress[T](const pyConfig.Config &conf, 
                        const T *data, size_t &cmpSize)
    void SZ_decompress[T](pyConfig.Config &conf, 
                        char *cmpData, 
                        size_t cmpSize, 
                        T *&decData)
    T *SZ_decompress[T](pyConfig.Config &conf, 
                        char *cmpData, 
                        size_t cmpSize)

cdef extern from "SZ3/utils/Statistic.hpp" namespace "SZ3":
    void verify[Type](Type *ori_data, Type *data, size_t num_elements)
