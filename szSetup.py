# from setuptools import setup, find_packages
# from setuptools.extension import Extension
# from setuptools.command.build_ext import build_ext
# from distutils import log as distutils_logger
# from distutils.errors import DistutilsSetupError

# import os
# import subprocess
# import setuptools

# SZ_DOWNLOAD_PATH = 'https://github.com/szcompressor/SZ.git'

# def download_file(url):
#     import requests
#     # require the last word in url as fname
#     fname = url.split("/")[-1]
#     r = requests.get(url)
#     # 'wb': write & binary mode
#     with open(fname, 'wb') as f:
#         f.write(r.content)

# def has_flag(compiler, flagname):
#     """Check whether a flag is supported on a compiler."""
#     import tempfile
#     from distutils.errors import CompileError
#     with tempfile.NamedTemporaryFile('w', suffix='.cpp') as f:
#         f.write('int main (int argc, char **argv) { return 0; }')
#         try:
#             compiler.compile([f.name], extra_postargs=[flagname])
#         except CompileError:
#             return False
#     return True


# def flag_filter(compiler, *flags):
#     """
#     Filter flags, returns list of accepted flags
#     Code borrowed from: https://github.com/navjotk/pyzfp

#     """
#     result = []
#     for flag in flags:
#         if has_flag(compiler, flag):
#             result.append(flag)
#     return result
