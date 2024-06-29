
cdef extern from "sz.h":
    ctypedef struct sz_params:
        int dataType
        unsigned int max_quant_intervals
        unsigned int quantization_intervals
        unsigned int maxRangeRadius
        int sol_ID
        int losslessCompressor
        int sampleDistance
        float predThreshold
        int szMode
        int gzipMode
        int errorBoundMode
        double absErrBound
        double relBoundRatio
        double psnr
        double normErr
        double pw_relBoundRatio
        int segment_size
        int pwr_type
        int protectValueRange
        float fmin, fmax
        double dmin, dmax
        int snapshotCmprStep
        int predictionMode
        int accelerate_pw_rel_compression
        int plus_bits
        int randomAccess
        int withRegression

    cdef int SZ_Init(const char *);
    cdef void SZ_Finalize();

cdef extern from "unistd.h":
    cdef int access(const char *pathname, int mode);

def f1():
    cdef const char * cfgFilePath = "/home/pysz/SZ/example/sz.config"
    SZ_Init(cfgFilePath)
    print("initiation succeeded")
    SZ_Finalize()
    cdef sz_params sp;
    print(sp.dataType)
    return 0