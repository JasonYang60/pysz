from pysz cimport pyConfig
#from libcpp.memory cimport unique_ptr
       

cdef extern from "SZ3/api/sz.hpp":
    char *SZ_compress[T](const pyConfig.Config &conf, 
                const T *data, size_t &cmpSize)

cdef extern from "SZ3/utils/FileUtil.hpp" namespace "SZ3":
    void readfile[Type](const char *file, const size_t num, Type *data)
    #unique_ptr[Type[]] readfile[Type](const char *file, size_t &num)
    void writefile[Type](const char *file, Type *data, size_t num_elements)


