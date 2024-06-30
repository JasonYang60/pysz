from libcpp.string cimport string
from libcpp cimport bool
from libc.stdint cimport uint8_t
from libcpp.vector cimport vector
from libcpp.memory cimport unique_ptr

cdef extern from "SZ3/utils/Config.hpp" namespace "SZ3":
    cdef enum EB:
        EB_ABS
        EB_REL
        EB_PSNR
        EB_L2NORM
        EB_ABS_AND_REL
        EB_ABS_OR_REL
    
    cdef enum ALGO:
        ALGO_LORENZO_REG
        ALGO_INTERP_LORENZO
        ALGO_INTERP

    cdef enum INTERP_ALGO:
        INTERP_ALGO_LINEAR 
        INTERP_ALGO_CUBIC

    cdef cppclass Config:
        size_t setDims[Iter](Iter begin, Iter end)
        void loadcfg(const string &cfgpath) 
        char N
        vector[size_t] dims
        size_t num 
        uint8_t cmprAlgo
        uint8_t errorBoundMode 
        double absErrorBound 
        double relErrorBound 
        double psnrErrorBound 
        double l2normErrorBound 
        bool lorenzo 
        bool lorenzo2 
        bool regression 
        bool regression2 
        bool openmp 
        uint8_t lossless # 0-> skip lossless(use lossless_bypass); 1-> zstd
        uint8_t encoder # 0-> skip encoder; 1->HuffmanEncoder; 2->ArithmeticEncoder
        uint8_t interpAlgo 
        uint8_t interpDirection 
        int interpBlockSize
        int quantbinCnt
        int blockSize
        int stride #not used now
        int pred_dim # not used now

cdef extern from "SZ3/api/sz.hpp":
    char *SZ_compress[T](const Config &conf, 
                const T *data, size_t &cmpSize)

cdef extern from "SZ3/utils/FileUtil.hpp" namespace "SZ3":
    void readfile[Type](const char *file, const size_t num, Type *data)
    #unique_ptr[Type[]] readfile[Type](const char *file, size_t &num)
    void writefile[Type](const char *file, Type *data, size_t num_elements)

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
