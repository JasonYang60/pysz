from setuptools import setup, find_packages
from setuptools.extension import Extension

def download_file(url, dest):
    import requests
    response = requests.get(url, stream = True)
    with open(dest, 'wb') as file:
        for chunk in response.iter_content(chunk_size = 8192):
            if chunk:
                file.write(chunk)  

def modify_cmake_lists_to_disable_zstd_pkg(cmakelist_path):
    with open(cmakelist_path, 'r') as file:
        lines = file.readlines()
    for i, line in enumerate(lines):
        if "pkg_search_module(ZSTD IMPORTED_TARGET libzstd)" in line:
            lines[i] = "# pkg_search_module(ZSTD IMPORTED_TARGET libzstd)\n"
    with open(cmakelist_path, 'w') as file:
        file.writelines(lines)

def run_command(command, cwd = None):
    import subprocess
    process = subprocess.Popen(command, shell=True, cwd=cwd)
    process.communicate()
    if process.returncode != 0:
        raise Exception(f"Command '{command}' failed with return code {process.returncode}")

def build_cxx(src_path):
    import os
    build_dir = os.path.join(src_path, "build")
    os.makedirs(build_dir, exist_ok=True)
    print("Running cmake...")
    run_command("cmake ..", cwd=build_dir)
    print("Running make...")
    run_command("make", cwd=build_dir)

def main():
    import shutil
    import os

    # If c++ file already compiled
    if os.path.exists("SZ3-master/build"):
        print("SZ3 lib found")
        return

    repo_url = "https://github.com/szcompressor/SZ3/archive/refs/heads/master.zip"
    download_dest = "master.zip"
    extract_dest = "./"

    # download src code(packed .zip file)
    print("Downloading code from Github...")
    download_file(repo_url, download_dest)

    # unpack it to extract_dest
    print("Extracting downloaded file...")
    
    shutil.unpack_archive(download_dest, extract_dest)
    os.remove(download_dest)

    # compile & build from c++ file, c++ 17 standard required
    build_cxx("SZ3-master")

if __name__ == "__main__":
    main()
# ------------------------------------------------------
def extensions():
    from Cython.Build import cythonize
    exts = []
    
    exts.append(Extension("pysz.pyConfig",
                    sources=["pysz/pyConfig.pyx"],
                    include_dirs=['SZ3-master/include',
                                'SZ3-master/build/include'],
                    libraries=["SZ3c","zstd"],  # Unix-like specific,
                    library_dirs=["SZ3-master/build/tools/sz3c", 
                                "SZ3-master/build/tools/zstd"],
                    language='c++',
                    extra_compile_args=['-std=c++17'],
                    # extra_link_args=['-Wl,-rpath,/usr/local/lib']
                    ))

    exts.append(Extension("pysz.sz",
                    sources=["pysz/sz.pyx"],
                    include_dirs=['SZ3-master/include',
                                'SZ3-master/build/include'],
                    libraries=["SZ3c","zstd"],  # Unix-like specific,
                    library_dirs=["SZ3-master/build/tools/sz3c", 
                                "SZ3-master/build/tools/zstd"],
                    language='c++',
                    extra_compile_args=['-std=c++17'],
                    # extra_link_args=['-Wl,-rpath,/usr/local/lib']
                    ))
    return cythonize(exts)


with open("README.md", "r") as fh:
    long_description = fh.read()

from Cython.Build import cythonize

configuration = {
    #'name': 'pysz',
    'packages': find_packages(),
    #'setup_requires': ['cython>=3.0.10', 'requests',],
    'ext_modules': extensions(),
    #'use_scm_version': True,
    #'description': "A python wrapper for the SZ3 compression library",
    #'long_description': long_description,
    #'long_description_content_type': 'text/markdown',
    #'url': 'https://github.com/JasonYang60/pysz',
    #'author': "Jason Yang",
    #'author_email': 'jason.neptune.yang@gmail.com',
    #'license': 'MIT',
    #'install_requires': [
    #    'cython>=3.0.10'
    #],
}

setup(**configuration)

