# Import the interface definitions
from pysz cimport compress

def f1():
    # Use the defined constants
    print("SZ_FLOAT:", compress.SZ_FLOAT)
    print("initiation succeeded")
    return 0