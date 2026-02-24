from setuptools import setup, Extension
from Cython.Build import cythonize
import numpy as np

extensions = [
    Extension(
        name="aged",
        sources=["aged.pyx", "../src/aged_scalar.cpp"],
        include_dirs=[np.get_include(), "../include"],
        language="c++",
        extra_compile_args=["-O3", "-std=c++17"]
    )
]

setup(
    name="aged_despill",
    version="1.0.0",
    ext_modules=cythonize(extensions),
    zip_safe=False,
)