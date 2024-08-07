from setuptools import setup, find_packages
from setuptools.extension import Extension

branch = 'bio'
# branch = 'main'

def download_file(url, dest):
    import requests
    response = requests.get(url, stream = True)
    with open(dest, 'wb') as file:
        for chunk in response.iter_content(chunk_size = 8192):
            if chunk:
                file.write(chunk)  

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
    if os.path.exists("SZ3-" + branch + "/build"):
        print("SZ3 lib found")
        return

    repo_url = "https://github.com/szcompressor/SZ3/archive/refs/heads/" + branch + ".zip"
    download_dest = "sz.zip"
    extract_dest = "./"

    # download src code(packed .zip file)
    print("Downloading code from Github...")
    download_file(repo_url, download_dest)

    # unpack it to extract_dest
    print("Extracting downloaded file...")
    
    shutil.unpack_archive(download_dest, extract_dest)
    os.remove(download_dest)

    # compile & build from c++ file, c++ 17 standard required
    build_cxx("SZ3-" + branch)

if __name__ == "__main__":
    main()

# ------------------------------------------------------
def extensions():
    from Cython.Build import cythonize
    exts = []
    
    exts.append(Extension("pysz.pyConfig",
                    sources=["pysz/pyConfig.pyx"],
                    include_dirs=['SZ3-' + branch + '/include',
                                'SZ3-' + branch + '/build/include'],
                    libraries=["SZ3c","zstd"],  # Unix-like specific,
                    library_dirs=["SZ3-" + branch + "/build/tools/sz3c", 
                                "SZ3-" + branch + "/build/tools/zstd"],
                    language='c++',
                    extra_compile_args=['-std=c++17'],
                    ))

    exts.append(Extension("pysz.sz",
                    sources=["pysz/sz.pyx"],
                    include_dirs=['SZ3-' + branch + '/include',
                                'SZ3-' + branch + '/build/include'],
                    libraries=["SZ3c","zstd"],  # Unix-like specific,
                    library_dirs=["SZ3-" + branch + "/build/tools/sz3c", 
                                "SZ3-" + branch + "/build/tools/zstd"],
                    language='c++',
                    extra_compile_args=['-std=c++17'],
                    ))
    return cythonize(exts)


with open("README.md", "r") as fh:
    long_description = fh.read()

from Cython.Build import cythonize

configuration = {
    'packages': find_packages(),
    'ext_modules': extensions(),
}

setup(**configuration)

