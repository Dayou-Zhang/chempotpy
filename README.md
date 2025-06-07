
ChemPotPy, CHEMical library of POTential energy surfaces in PYthon 
==================================================================

June 7, 2025

Authors: Yinan Shu, Zoltan Varga, Dayou Zhang, Donald G. Truhlar
University of Minnesota, Minnesota, United States

ChemPotPy is a library for analytic representation of single-state 
and multi-state potential energy surfaces and couplings. 

All fortran source code are stored in folder chempotpy 


How to install
--------------
Users can install the stable release using:

```
pip install chempotpy
```

We provide pre-compiled binary wheels for Linux x86_64 platform. By default
the above command will install the binary wheels. They should work on the
vast majority of desktop and server Linux distributions. 
The binary wheels are compiled against OpenBLAS for surfaces requiring BLAS
and LAPACK routines. The OpenBLAS library is included in the binary wheels.

Users also have the option to compile the potential energy surface libraries
from source. Detailed instructions on installing from source can be found
below.

<details>
<summary>Instructions for installing from source (click here to expand)</summary>
    
* Ensure your system have a working Fortran and C compiler, as well as a working
  BLAS and LAPACK library installed

* Start compiling:

```
pip install chempotpy --no-binary chempotpy --verbose
```

  The build system will install all build dependencies automatically (including
  CMake). It will then configure, build, and install the package. The entire
  process takes about 20-30 minutes on a 4-processor computation node.

  If CMake cannot locate the desired BLAS and/or LAPACK library, you can try again
  after setting environmental variables such as `BLA_VENDOR`. See the CMake
  [documentation](https://cmake.org/cmake/help/latest/module/FindBLAS.html) for more details.

</details>

<details>
<summary>Legacy instructions for chempotpy 1.0.x (click here to expand)</summary>

* Create a conda virtual environment with gfortran and MKL:
    
       conda create --name chempotpy
       conda activate chempotpy
       conda install python=3.11
       conda install mkl mkl-service
       conda install -c conda-forge gfortran
       pip install numpy "numpy>=1.26,<1.27"
       pip install charset_normalizer

* Install stable release:
  
        pip install chempotpy



* The users may re-compile all .so modules for compatability reasons:

  get into the parent directory of chempotpy 
   
        make all 
        make check

</details>

Compile Chempotpy subroutine
----------------------------
One can use the meta programming script to automatically generate a 
fortran subroutine. 

  get into the parent directory of chempotpy/chempotpy

```
./meta_chempotpy.script
```

The meta program will generate a fortran subroutine called chempotpy. 
One can interface this chempotpy subroutine with any dynamics code. 
Notice that the meta program will also generate sub programs for each 
surface that is located in chempotpy/chempotpy/system/lib/.


Citation
--------

The following paper should be cited in publications utilizing the
ChemPotPy library in addition to the original paper that publishes 
the potential energy surface subroutine:

Shu, Y.; Varga, Z.; Truhlar, D. G.
"ChemPotPy: A Python Library for Analytic Representation of Potential 
Energy Surfaces and Diabatic Potential Energy Matrices"
accepted by J. Phys. Chem. A


TO CONTRIBUTE YOUR POTENTIAL or report a bug
--------------------------------------------
* Option 1
Send email to one of the maintainers:
  - Yinan Shu, yinan.shu.0728@gmail.com
  - Zoltan Varga, zoltan78varga@gmail.com
  - Dayou Zhang, zhan6350@umn.edu
  - Donald G. Truhlar, truhlar@umn.edu
 
* Option 2
Submit tickets on the [issues](https://github.com/shuyinan/chempotpy/issues)
