# Kokkos install cheat sheet

1. [Requirements](#requirements)
	1. [Compiler](#compiler)
	2. [Build system](#build-system)
2. [How to build Kokkos](#how-to-build-kokkos)
	1. [As part of your application](#as-part-of-your-application)
	2. [As an external library](#as-an-external-library)
		1. [Configure, build and install Kokkos](#configure-build-and-install-kokkos)
		2. [Use in your code](#use-in-your-code)
		3. [Select options](#select-options)
			1. [Host backends](#host-backends)
			2. [GPU backends](#gpu-backends)
			5. [Specific options](#specific-options)
			6. [Architecture-specific options](#architecture-specific-options)
		4. [Command examples for the latest architectures](#command-examples-for-the-latest-architectures)
		5. [Third-party Libraries (TPLs)](#third-party-libraries-tpls)
	3. [As a Spack package](#as-a-spack-package)

<img title="Doc" alt="Doc" src="./images/documentation.png" height="20"> https://kokkos.org/kokkos-core-wiki/ProgrammingGuide/Compiling.html

<img title="Doc" alt="Doc" src="./images/documentation.png" height="20"> https://kokkos.org/kokkos-core-wiki/building.html

<img title="Doc" alt="Doc" src="./images/training.png" height="20"> https://github.com/kokkos/kokkos-tutorials/blob/main/LectureSeries/KokkosTutorial_01_Introduction.pdf

## Requirements

### Compiler

| Compiler  | Minimum version | Note     |
|-----------|-----------------|----------|
| GCC       | 5.3.0           |          |
| Clang     | 4.0.0           |          |
| Clang     | 10.0.0          | For CUDA |
| ARM Clang | 20.1            |          |
| Intel     | 17.0.1          |          |
| NVCC      | 9.2.88          |          |
| PGI/NVHPC | 21.5            |          |
| ROCM      | 4.5             |          |
| MSVC      | 19.29           |          |
| IBM XL    | 16.1.1          |          |
| Fujitsu   | 4.5.0           |          |

### Build system

| Build system | Minimum version | Note                                                                                          |
|--------------|-----------------|-----------------------------------------------------------------------------------------------|
| CMake        | 3.16            | Minimum requirement                                                                           |
| CMake        | 3.18            | For Fortran linkage. This does not affect most mixed Fortran/Kokkos builds. See build issues. |
| CMake        | 3.21.1          | For NVHPC compiler                                                                            |
| CMake        | 3.25.2          | For LLVM Intel compiler                                                                       |

<img title="Doc" alt="Doc" src="./images/documentation.png" height="20"> https://kokkos.org/kokkos-core-wiki/requirements.html

## How to build Kokkos

### As part of your application

```cmake
# CMakeLists.txt

add_subdirectory(path/to/kokkos)
target_link_libraries(
    my-lib
    PRIVATE
        Kokkos::kokkos
)
```

<img title="Code" alt="Code" src="./images/code.png" height="20"> Code example:

- https://github.com/kokkos/kokkos/tree/master/example/build_cmake_in_tree

### As an external library

#### Configure, build and install Kokkos

```bash
cd path/to/kokkos
cmake -B build \
    -DCMAKE_CXX_COMPILER=<your C++ compiler> \
    -DCMAKE_INSTALL_PREFIX=path/to/kokkos/install \
    <other options discussed below>
cmake --build build
cmake --install build
```

<img title="Doc" alt="Doc" src="./images/documentation.png" height="20"> https://kokkos.org/kokkos-core-wiki/building.html

#### Use in your code

```cmake
# CMakeLists.txt

find_package(Kokkos REQUIRED)
target_link_libraries(
    my-lib
    PRIVATE
        Kokkos::kokkos
)
```

```sh
cd path/to/your/code
cmake -B build \
    -DCMAKE_CXX_COMPILER=<your C++ compiler> \
    -DCMAKE_PREFIX_PATH=path/to/kokkos/install \
    <other options discussed below>
```

<img title="Doc" alt="Doc" src="./images/documentation.png" height="20"> https://cmake.org/cmake/help/latest/guide/tutorial/index.html

#### Select options

##### Host backends

| Option                       | Backend | Notes           |
|------------------------------|---------|-----------------|
| `-DKokkos_ENABLE_SERIAL=ON`  | Serial  | `ON` by default |
| `-DKokkos_ENABLE_OPENMP=ON`  | OpenMP  |                 |
| `-DKokkos_ENABLE_PTHREAD=ON` | PThread |                 |

##### Device backends

| Option                            | Backend       | Notes        | Extra steps                                                                |
|-----------------------------------|---------------|--------------|----------------------------------------------------------------------------|
| `-DKokkos_ENABLE_CUDA=ON`         | CUDA          |              | See NVIDIA [architecture-specific options](#architecture-specific-options) |
| `-DKokkos_ENABLE_HIP=ON`          | HIP           |              | See AMD [architecture-specific options](#architecture-specific-options)    |
| `-DKokkos_ENABLE_SYCL=ON`         | SYCL          | Experimental | See Intel [architecture-specific options](#architecture-specific-options)  |
| `-DKokkos_ENABLE_OPENMPTARGET=ON` | OpenMP target | Experimental |                                                                            |
| `-DKokkos_ENABLE_HPX=ON`          | HPX           | Experimental |                                                                            |

<img title="Warning" alt="Warning" src="./images/warning.png" height="15"> You can only select `SERIAL`, plus one host backend and one device backend at a time.

##### Specific options

| Option                                           | Description                                                |
|--------------------------------------------------|------------------------------------------------------------|
| `-DKokkos_ENABLE_AGGRESSIVE_VECTORIZATION=ON`    | Aggressively vectorize loops                               |
| `-DKokkos_ENABLE_COMPILER_WARNINGS=ON`           | Print all compiler warnings                                |
| `-DKokkos_ENABLE_DEBUG_BOUNDS_CHECK=ON`          | Use bounds checking - will increase runtime                |
| `-DKokkos_ENABLE_DEBUG_DUALVIEW_MODIFY_CHECK=ON` | Debug check on dual views                                  |
| `-DKokkos_ENABLE_DEBUG=ON`                       | Activate extra debug features - may increase compile times |
| `-DKokkos_ENABLE_DEPRECATED_CODE=ON`             | Enable deprecated code                                     |
| `-DKokkos_ENABLE_EXAMPLES=ON`                    | Enable building examples                                   |
| `-DKokkos_ENABLE_LARGE_MEM_TESTS=ON`             | Perform extra large memory tests                           |
| `-DKokkos_ENABLE_TESTS=ON`                       | Enable building tests                                      |
| `-DKokkos_ENABLE_TUNING=ON`                      | Create bindings for tuning tools                           |

##### Architecture-specific options

| Option                    | Description                              |
|---------------------------|------------------------------------------|
| `-DKokkos_ARCH_NATIVE=ON` | Optimize for the local host architecture |

<details>
<summary>AMD CPU architectures</summary>

| Option                    | Description                      |
|---------------------------|----------------------------------|
| `-DKokkos_ARCH_ZEN3=ON`   | Optimize for Zen3 architecture   |
| `-DKokkos_ARCH_ZEN2=ON`   | Optimize for Zen2 architecture   |
| `-DKokkos_ARCH_ZEN=ON`    | Optimize for Zen architecture    |

</details>

<details>
<summary>ARM CPU architectures</summary>

| Option                             | Description                                   |
|------------------------------------|-----------------------------------------------|
| `-DKokkos_ARCH_A64FX=ON`           | Optimize for ARMv8.2 with SVE Support         |
| `-DKokkos_ARCH_ARMV81=ON`          | Optimize for ARMV81 architecture              |
| `-DKokkos_ARCH_ARMV80=ON`          | Optimize for ARMV80 architecture              |

</details>

<details>
<summary>Intel CPU architectures</summary>

| Option                | Description                                               |
|-----------------------|-----------------------------------------------------------|
| `-DKokkos_ARCH_SPR=ON | Optimize for Sapphire Rapids architecture                 |
| `-DKokkos_ARCH_SKX=ON | Optimize for Skylake architecture                         |
| `-DKokkos_ARCH_BDW=ON | Optimize for Intel Broadwell processor architecture       |
| `-DKokkos_ARCH_HSW=ON | Optimize for Intel Haswell processor architecture         |
| `-DKokkos_ARCH_KNL=ON | Optimize for Intel Knights Landing processor architecture |
| `-DKokkos_ARCH_SNB=ON | Optimize for Sandy Bridge architecture                    |

</details>

<details>
<summary>AMD GPU architectures (HIP)</summary>

| Option                         | Description                   | Associated cards     |
|--------------------------------|-------------------------------|----------------------|
| `-DKokkos_ARCH_AMD_GFX90A=ON`  | Optimize for AMD GFX90A GPUs  | MI210, MI250, MI250X |
| `-DKokkos_ARCH_AMD_GFX908=ON`  | Optimize for AMD GFX908 GPUs  | MI100                |
| `-DKokkos_ARCH_AMD_GFX906=ON`  | Optimize for AMD GFX906 GPUs  | MI50/MI60            |
| `-DKokkos_ARCH_AMD_GFX1100=ON` | Optimize for AMD GFX1100 GPUs | 7900xt               |
| `-DKokkos_ARCH_AMD_GFX1030=ON` | Optimize for AMD GFX1030 GPUs | V620, W6800          |

| Option                                                  | Description                                                                                   |
|---------------------------------------------------------|-----------------------------------------------------------------------------------------------|
| `-DKokkos_ENABLE_HIP_MULTIPLE_KERNEL_INSTANTIATIONS=ON` | Instantiate multiple kernels at compile time; improves performance but increases compile time |
| `-DKokkos_ENABLE_HIP_RELOCATABLE_DEVICE_CODE=ON`        | Enable Relocatable Device Code (RDC) for HIP                                                  |

</details>

<details>
<summary>Intel GPU architectures (SYCL)</summary>

| Option                         | Description                                       |
|--------------------------------|---------------------------------------------------|
| `-DKokkos_ARCH_INTEL_XEHP=ON`     | Optimize for Intel GPU Xe-HP                      |
| `-DKokkos_ARCH_INTEL_PVC=ON`      | Optimize for Intel GPU Ponte Vecchio/GPU Max      |
| `-DKokkos_ARCH_INTEL_GEN=ON`   | Optimize for Intel GPUs, Just-In-Time compilation |
| `-DKokkos_ARCH_INTEL_DG1=ON`   | Optimize for Intel Iris XeMAX GPU                 |
| `-DKokkos_ARCH_INTEL_GEN12=ON` | Optimize for Intel GPU Gen12                      |
| `-DKokkos_ARCH_INTEL_GEN11=ON` | Optimize for Intel GPU Gen11                      |

</details>

<details>
<summary>NVIDIA GPU architectures (CUDA)</summary>

| Option                    | Description                                  | Compute Capability | Associated cards                                     |
|---------------------------|----------------------------------------------|--------------------|------------------------------------------------------|
| `-DKokkos_ARCH_AMPERE90`  | Optimize for the NVIDIA Ampere architecture  | 9.0                | Hopper H200, H100                                    |
| `-DKokkos_ARCH_ADA89`     | Optimize for the NVIDIA Ada architecture     | 8.9                | GeForce RTX 40 series, RTX 6000/5000 series, Ada L4X |
| `-DKokkos_ARCH_AMPERE86`  | Optimize for the NVIDIA Ampere architecture  | 8.6                | GeForce RTX 30 series, RTX A series, Ampere A40      |
| `-DKokkos_ARCH_AMPERE80`  | Optimize for the NVIDIA Ampere architecture  | 8.0                | Ampere A100                                          |
| `-DKokkos_ARCH_TURING75`  | Optimize for the NVIDIA Turing architecture  | 7.5                | Turing T4                                            |
| `-DKokkos_ARCH_VOLTA72`   | Optimize for the NVIDIA Volta architecture   | 7.2                |                                                      |
| `-DKokkos_ARCH_VOLTA70`   | Optimize for the NVIDIA Volta architecture   | 7.0                | Volta V100                                           |
| `-DKokkos_ARCH_PASCAL61`  | Optimize for the NVIDIA Pascal architecture  | 6.1                | Pascal P40, P6, P4                                   |
| `-DKokkos_ARCH_PASCAL60`  | Optimize for the NVIDIA Pascal architecture  | 6.0                | Pascal P100                                          |
| `-DKokkos_ARCH_MAXWELL53` | Optimize for the NVIDIA Maxwell architecture | 5.3                |                                                      |
| `-DKokkos_ARCH_MAXWELL52` | Optimize for the NVIDIA Maxwell architecture | 5.2                | Maxwell M4, M40, M6, M60                             |
| `-DKokkos_ARCH_MAXWELL50` | Optimize for the NVIDIA Maxwell architecture | 5.0                | Maxwell M10                                          |
| `-DKokkos_ARCH_KEPLER37`  | Optimize for the NVIDIA Kepler architecture  | 3.7                | Kepler K80                                           |
| `-DKokkos_ARCH_KEPLER35`  | Optimize for the NVIDIA Kepler architecture  | 3.5                |                                                      |
| `-DKokkos_ARCH_KEPLER32`  | Optimize for the NVIDIA Kepler architecture  | 3.2                |                                                      |
| `-DKokkos_ARCH_KEPLER30`  | Optimize for the NVIDIA Kepler architecture  | 3.0                |                                                      |

<img title="Doc" alt="Doc" src="./images/documentation.png" height="20"> See NVIDIA documentation on Compute Capability (CC): https://developer.nvidia.com/cuda-gpus

| Option                                         | Description                                       |
|------------------------------------------------|---------------------------------------------------|
| `-DKokkos_ENABLE_CUDA_CONSTEXPR`               | Activate experimental relaxed constexpr functions |
| `-DKokkos_ENABLE_CUDA_LAMBDA`                  | Activate experimental lambda features             |
| `-DKokkos_ENABLE_CUDA_LDG_INTRINSIC`           | Use CUDA LDG intrinsics                           |
| `-DKokkos_ENABLE_CUDA_RELOCATABLE_DEVICE_CODE` | Enable relocatable device code (RDC) for CUDA     |

</details>

<img title="Doc" alt="Doc" src="./images/documentation.png" height="20"> For more, see https://kokkos.org/kokkos-core-wiki/keywords.html

#### Command examples for the latest architectures

<details>
<summary>For AMD MI250 GPUs with HIP and OpenMP support</summary>

```bash
cmake -B build -DKokkos_ENABLE_HIP=ON -DKokkos_ENABLE_OPENMP=ON -DKokkos_ARCH_AMD_GFX90A=ON -DCMAKE_CXX_COMPILER=hipcc
```

</details>

<details>
<summary>For NVIDIA A100 GPUs with CUDA and OpenMP support</summary>

```bash
cmake -B build -DKokkos_ENABLE_CUDA=ON -DKokkos_ARCH_AMPERE80=ON -DKokkos_ENABLE_OPENMP=ON
```

</details>

<details>
<summary>For NVIDIA V100 GPUs with CUDA and OpenMP support</summary>

```bash
cmake -B build -DKokkos_ENABLE_CUDA=ON -DKokkos_ARCH_VOLTA70=ON -DKokkos_ENABLE_OPENMP=ON
```

</details>

<details>
<summary>For Intel Ponte Vecchio (GPU Max) GPUs with SYCL and OpenMP support</summary>

```bash
cmake -B build -DKokkos_ENABLE_SYCL=ON -DKokkos_ARCH_INTEL_PVC=ON -DKokkos_ENABLE_OPENMP=ON -DCMAKE_CXX_COMPILER=icpx
```

</details>

<img title="Code" alt="Code" src="./images/code.png" height="20"> For more code examples:

- https://github.com/kokkos/kokkos/tree/master/example/build_cmake_installed
- https://github.com/kokkos/kokkos/tree/master/example/build_cmake_installed_different_compiler

#### Third-party Libraries (TPLs)

<img title="Doc" alt="Doc" src="./images/documentation.png" height="20"> See https://kokkos.org/kokkos-core-wiki/keywords.html#third-party-libraries-tpls

### As a Spack package

TODO finish this part

<img title="Doc" alt="Doc" src="./images/documentation.png" height="20"> See https://kokkos.org/kokkos-core-wiki/building.html#spack
