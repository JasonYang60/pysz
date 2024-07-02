from libcpp.string cimport string
from libc.stdlib cimport malloc, free
from pysz cimport pyConfig

# Define the macros as constants in Cython
cdef int SZ_FLOAT   = 0
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
cdef int SZ_TYPE_EMPTY = -1


cdef extern from "SZ3/utils/FileUtil.hpp" namespace "SZ3":
    void readfile[Type](const char *file, const size_t num, Type *data)
    void writefile[Type](const char *file, Type *data, size_t num_elements)

cdef extern from "SZ3/api/sz.hpp":
    char *SZ_compress[T](const pyConfig.Config &conf, 
                const T *data, size_t &cmpSize)
