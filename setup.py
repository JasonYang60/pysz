from setuptools import setup, find_packages
from setuptools.extension import Extension
# from setuptools.command.build_ext import build_ext
# from distutils import log as distutils_logger
# from distutils.errors import DistutilsSetupError

# import os
# import subprocess
# import setuptools

# class lazy_cythonize(list):
#     """
#     Code borrowed from: https://github.com/navjotk/pyzfp
    
#     """
#     def __init__(self, callback):
#         self._list, self.callback = None, callback

#     def c_list(self):
#         if self._list is None:
#             self._list = self.callback()
#         return self._list

#     def __iter__(self):
#         for e in self.c_list():
#             yield e

#     def __getitem__(self, ii):
#         return self.c_list()[ii]

#     def __len__(self):
#         return len(self.c_list())


def extensions():
    import numpy
    from Cython.Build import cythonize
    exts = []
    ext = Extension("pysz.compress",
                    sources=["pysz/compress.pyx"],
                    include_dirs=['SZ/sz/include',
                                  numpy.get_include()],
                    libraries=["SZ"],  # Unix-like specific,
                    library_dirs=["SZ/build/sz"],
                    language='c',
                    # extra_link_args=['-Wl,-rpath,/usr/local/lib']
                    )
    exts.append(ext)
    return cythonize(exts)


# class specialized_build_ext(build_ext, object):
#     """
#     Specialized builder for testlib library
#     Code borrowed from: https://stackoverflow.com/a/48641638

#     """
#     special_extension = "pysz"

#     def build_extension(self, ext):
#         # if has_flag(self.compiler, '-fopenmp'):
#         #     for ext in self.extensions:
#         #         ext.extra_compile_args += ['-fopenmp']
#         #         ext.extra_link_args += ['-fopenmp']
#         #     clang = False
#         # else:
#         #     clang = True
#         clang = True

#         if ext.name != self.special_extension:
#             # Handle unspecial extensions with the parent class' method
#             super(specialized_build_ext, self).build_extension(ext)
#         else:
#             # Handle special extension
#             sources = ext.sources
#             if sources is None or not isinstance(sources, (list, tuple)):
#                 raise DistutilsSetupError(
#                        "in 'ext_modules' option (extension '%s'), "
#                        "'sources' must be present and must be "
#                        "a list of source filenames" % ext.name)
#             sources = list(sources)
#             if len(sources) > 1:
#                 sources_path = os.path.commonpath(sources)
#             else:
#                 sources_path = os.path.dirname(sources[0])
#             sources_path = os.path.realpath(sources_path)
#             if not sources_path.endswith(os.path.sep):
#                 sources_path += os.path.sep

#             if not os.path.exists(sources_path) or \
#                not os.path.isdir(sources_path):
#                 raise DistutilsSetupError(
#                        "in 'extensions' option (extension '%s'), "
#                        "the supplied 'sources' base dir "
#                        "must exist" % ext.name)

#             download_file(SZ_DOWNLOAD_PATH)
#             command = 'make'
#             if clang:
#                 command += ' OPENMP=0'
#             else:
#                 command += ' OPENMP=1'

#             env_vars = ['CC', 'CXX', 'CFLAGS', 'FC']

#             for v in env_vars:
#                 val = os.getenv(v)
#                 if val is not None:
#                     command += ' %s=%s' % (v, val)

#             distutils_logger.info('Will execute the following command in ' +
#                                   'with subprocess.Popen:' +
#                                   '\n{0}'.format(command))
#             try:
#                 output = subprocess.check_output(command,
#                                                  cwd=sources_path,
#                                                  stderr=subprocess.STDOUT,
#                                                  shell=True)
#             except subprocess.CalledProcessError as e:
#                 distutils_logger.info(str(e.output))
#                 raise

#             distutils_logger.info(str(output))

#             # After making the library build the c library's python interface
#             # with the parent build_extension method
#             super(specialized_build_ext, self).build_extension(ext)

with open("README.md", "r") as fh:
    long_description = fh.read()

from Cython.Build import cythonize
configuration = {
    'name': 'pysz',
    'packages': find_packages(),
    'setup_requires': ['cython>=0.17', 'requests', 'numpy'],
    'ext_modules': extensions(),
    # # 'use_scm_version': True,
    #  # 'cmdclass': {'build_ext': specialized_build_ext},
    # 'description': "A python wrapper for the SZ compression libary",
    # 'long_description': long_description,
    # 'long_description_content_type': 'text/markdown',
    # 'url': 'https://github.com/yourusername/my_package',
    # 'author': "Jason Yang",
    # 'author_email': '',
    # 'license': 'MIT',
}


setup(**configuration)

# setup(
#     name='pysz',
#     version='0.0.1',
#     author='Jason Yang',
#     author_email='',
#     description='A simple test package',
#     long_description=open('README.md').read(),
#     long_description_content_type='text/markdown',
#     url='https://github.com/yourusername/my_package',
#     packages=find_packages(),
#     classifiers=[
#         'Programming Language :: Python :: 3',
#         'License :: OSI Approved :: MIT License',
#         'Operating System :: OS Independent',
#     ],
#     python_requires='>=3.10',
# )
