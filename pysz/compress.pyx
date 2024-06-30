# distutils: language = c++
# Import the interface definitions
from pysz cimport compress
cimport cython

cdef init_conf(Config &conf):
    conf.cmprAlgo = ALGO_INTERP_LORENZO;
    conf.errorBoundMode = EB_ABS;
    conf.absErrorBound = 0.0;
    conf.relErrorBound = 0.0;
    conf.psnrErrorBound = 0.0;
    conf.l2normErrorBound = 0.0;
    conf.lorenzo = True;
    conf.lorenzo2 = False;
    conf.regression = True;
    conf.regression2 = False;
    conf.openmp = False;
    conf.lossless = 1; # 0-> skip lossless(use lossless_bypass); 1-> zstd
    conf.encoder = 1;# 0-> skip encoder; 1->HuffmanEncoder; 2->ArithmeticEncoder
    conf.interpAlgo = INTERP_ALGO_CUBIC;
    conf.interpDirection = 0;
    conf.interpBlockSize = 32;
    conf.quantbinCnt = 65536;
    conf.blockSize = 0;
    conf.stride = 0;#not used now
    conf.pred_dim = 0; # not used now
    
from libc.stdlib cimport malloc
def compress_data():
                #const char *cmpPath, 
                #cmp.SZ3.Config conf):
    #cdef double data[8192] # conf.num = 8192
#    cdef char *result = SZ_compress(conf, &data[0], cmpSize)
    #inStr = ""
    #with open(inPath, 'rb') as f:
    #    inStr = f.read()
    #cdef char *inBytes = nullptr
    cdef string inPath = "testdouble_8_8_128.dat"
    cdef double *inBytes = <double *> malloc(8192 * sizeof(double))
    cdef char *inPathBytes = &inPath[0]
    print(inPathBytes)
    readfile[double](inPathBytes, 8192, inBytes)

    cdef Config conf
    init_conf(conf)
    cdef string cfgpath = "sz3.config"
    conf.loadcfg(&cfgpath[0])
    print("loading cfg completed")
    conf.blockSize = 6;
    cdef vector[size_t] dims = {128, 8, 8}
    conf.setDims(dims.begin(), dims.end())
    print("dim set")

    #cdef double *outBytes = inBytes
    cdef size_t outSize = 8192 * 2
    cdef char *outBytesPtr = SZ_compress[double](conf, inBytes, outSize)
    print("compress completed, outSize = ", outSize)
    cdef double *outBytes = <double*> outBytesPtr
    #if (cmpPath == nullptr):
    #    outputFilePath += "%s.sz" + inPath
    #else:
    cdef string suffix = ".sz"
    cdef string outputFilePath = inPath + suffix
    cdef char* outPathBytes = &outputFilePath[0]
    writefile[double](outPathBytes, outBytes, outSize)
    #cdef char *outCharPtr = <char*>outBytes
    #py_outBytes = <bytes> outCharPtr
    #with open(outputFilePath, 'wb') as f:
    #    f.write(py_outBytes)
    compression_ratio = conf.num * 1.0 * sizeof(double) / outSize
    print(f"compression ratio = {compression_ratio:.2f}")
#    write_char_array_to_file(data, 8192, outputFilePath)

# file_writer.pyx
def f1():
    # Use the defined constants
    print("SZ_FLOAT:", compress.SZ_FLOAT)
    print("initiation succeeded")
    return 0