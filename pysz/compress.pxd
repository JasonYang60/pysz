cdef extern from "SZ3/utils/Config.hpp" namespace "SZ3":
    cdef cppclass Config:
        pass

cdef extern from "SZ3/api/sz.hpp":
    char *SZ_compress[T](const Config &conf, 
                const T *data, size_t &cmpSize)

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
