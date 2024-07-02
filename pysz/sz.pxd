from libcpp.string cimport string
from libc.stdlib cimport malloc, free
from pysz cimport pyConfig

cdef extern from "SZ3/utils/FileUtil.hpp" namespace "SZ3":
    void readfile[Type](const char *file, const size_t num, Type *data)
    void writefile[Type](const char *file, Type *data, size_t num_elements)

cdef extern from "SZ3/api/sz.hpp":
    char *SZ_compress[T](const pyConfig.Config &conf, 
                const T *data, size_t &cmpSize)