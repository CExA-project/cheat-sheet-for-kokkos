---
title: Installation cheat sheet for Kokkos
---

<!--#ifndef PRINT-->

# Kokkos install cheat sheet

1. [title: Installation cheat sheet for Kokkos](#title-installation-cheat-sheet-for-kokkos)
2. [Requirements](#requirements)
	1. [Compiler](#compiler)
	2. [Build system](#build-system)
3. [How to build Kokkos](#how-to-build-kokkos)
	1. [As part of your application](#as-part-of-your-application)
	2. [As an external library](#as-an-external-library)
		1. [Configure, build and install Kokkos](#configure-build-and-install-kokkos)
		2. [Use in your code](#use-in-your-code)
	3. [As a Spack package](#as-a-spack-package)
4. [Kokkos compile options](#kokkos-compile-options)
	1. [Host backends](#host-backends)
	2. [Device backends](#device-backends)
	3. [Specific options](#specific-options)
	4. [Architecture-specific options](#architecture-specific-options)
		1. [Host architectures](#host-architectures)
			1. [AMD CPU architectures](#amd-cpu-architectures)
			2. [ARM CPU architectures](#arm-cpu-architectures)
			3. [Intel CPU architectures](#intel-cpu-architectures)
		2. [Device architectures](#device-architectures)
			1. [AMD GPU architectures (HIP)](#amd-gpu-architectures-hip)
			2. [Intel GPU architectures (SYCL)](#intel-gpu-architectures-sycl)
			3. [NVIDIA GPU architectures (CUDA)](#nvidia-gpu-architectures-cuda)
	3. [Third-party Libraries (TPLs)](#third-party-libraries-tpls)
	4. [Examples for the most common architectures](#examples-for-the-most-common-architectures)
		1. [Local CPU with OpenMP](#local-cpu-with-openmp)
		2. [AMD MI250 GPU with HIP and OpenMP](#amd-mi250-gpu-with-hip-and-openmp)
		3. [NVIDIA A100 GPU with CUDA and OpenMP](#nvidia-a100-gpu-with-cuda-and-openmp)
		4. [NVIDIA V100 GPU with CUDA and OpenMP](#nvidia-v100-gpu-with-cuda-and-openmp)
		5. [Intel GPU Max/Ponte Vecchio GPU with SYCL and OpenMP](#intel-gpu-maxponte-vecchio-gpu-with-sycl-and-openmp)

<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://kokkos.org/kokkos-core-wiki/ProgrammingGuide/Compiling.html

<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://kokkos.org/kokkos-core-wiki/building.html

<img title="Doc" alt="Doc" src="./images/tutorial_txt.svg" height="25"> https://github.com/kokkos/kokkos-tutorials/blob/main/LectureSeries/KokkosTutorial_01_Introduction.pdf

<!--#endif-->

## Requirements

### Compiler

| Compiler      | Minimum version | Notes    |
|---------------|-----------------|----------|
| ARM Clang     | 20.1            |          |
| Clang         | 10.0.0          | For CUDA |
| Clang         | 8.0.0           | For CPU  |
| GCC           | 8.2.0           |          |
| Intel Classic | 19.0.5          |          |
| Intel LLVM    | 2022.0.0        | For SYCL |
| Intel LLVM    | 2021.1.1        | For CPU  |
| MSVC          | 19.29           |          |
| NVCC          | 11.0            |          |
| NVHPC/PGI     | 22.3            |          |
| ROCM          | 5.2.0           |          |

### Build system

| Build system | Minimum version | Notes                       |
|--------------|-----------------|-----------------------------|
| CMake        | 3.25.2          | For Intel LLVM full support |
| CMake        | 3.21.1          | For NVHPC support           |
| CMake        | 3.18            | For better Fortran linking  |
| CMake        | 3.16            |                             |


<!--#ifndef PRINT-->
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://kokkos.org/kokkos-core-wiki/requirements.html
<!--#endif-->

## How to build Kokkos

### As part of your application

```cmake
add_subdirectory(path/to/kokkos)
target_link_libraries(
    my-app
    Kokkos::kokkos
)
```

```sh
cd path/to/your/code
cmake -B build \
    -DCMAKE_CXX_COMPILER=<your C++ compiler> \
    <Kokkos compile options>
```

<!--#ifndef PRINT-->
<img title="Code" alt="Code" src="./images/code_txt.svg" height="25"> Code example:

- https://github.com/kokkos/kokkos/tree/master/example/build_cmake_in_tree
<!--#endif-->

### As an external library

#### Configure, build and install Kokkos

```sh
cd path/to/kokkos
cmake -B build \
    -DCMAKE_CXX_COMPILER=<your C++ compiler> \
    -DCMAKE_INSTALL_PREFIX=path/to/kokkos/install \
    <Kokkos compile options>
cmake --build build
cmake --install build
```

<!--#ifndef PRINT-->
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://kokkos.org/kokkos-core-wiki/building.html
<!--#endif-->

#### Use in your code

```cmake
find_package(Kokkos REQUIRED)
target_link_libraries(
    my-app
    Kokkos::kokkos
)
```

```sh
cd path/to/your/code
cmake -B build \
    -DCMAKE_CXX_COMPILER=<your C++ compiler> \
    -DKokkos_ROOT=path/to/kokkos/install
```

<!--#ifndef PRINT-->
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://cmake.org/cmake/help/latest/guide/tutorial/index.html
<!--#endif-->

<!--#ifndef PRINT-->

### As a Spack package

TODO finish this part

<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> See https://kokkos.org/kokkos-core-wiki/building.html#spack

<!--#endif-->

## Kokkos compile options

### Host backends

| Option                       | Backend |
|------------------------------|---------|
| `-DKokkos_ENABLE_SERIAL=ON`  | Serial  |
| `-DKokkos_ENABLE_OPENMP=ON`  | OpenMP  |
| `-DKokkos_ENABLE_THREADS=ON` | Threads |

<img title="Warning" alt="Warning" src="./images/warning_txt.svg" height="25"> The serial backend is enabled by default if no other host backend is enabled.

### Device backends

| Option                    | Backend | Device |
|---------------------------|---------|--------|
| `-DKokkos_ENABLE_CUDA=ON` | CUDA    | NVIDIA |
| `-DKokkos_ENABLE_HIP=ON`  | HIP     | AMD    |
| `-DKokkos_ENABLE_SYCL=ON` | SYCL    | Intel  |

<img title="Warning" alt="Warning" src="./images/warning_txt.svg" height="25"> You can only select the serial backend, plus another host backend and one device backend at a time.

See [architecture-specific options](#architecture-specific-options).

### Specific options

| Option                                  | Description                                               |
|-----------------------------------------|-----------------------------------------------------------|
| `-DKokkos_ENABLE_DEBUG=ON`              | Activate extra debug features, may increase compile times |
| `-DKokkos_ENABLE_DEBUG_BOUNDS_CHECK=ON` | Use bounds checking, will increase runtime                |
| `-DKokkos_ENABLE_EXAMPLES=ON`           | Build examples                                            |
| `-DKokkos_ENABLE_TUNING=ON`             | Create bindings for tuning tools                          |

<!--#ifndef PRINT-->
<details>
<summary>Extra options</summary>

| Option                                           | Description                                |
|--------------------------------------------------|--------------------------------------------|
| `-DKokkos_ENABLE_AGGRESSIVE_VECTORIZATION=ON`    | Aggressively vectorize loops               |
| `-DKokkos_ENABLE_DEBUG_DUALVIEW_MODIFY_CHECK=ON` | Debug check on dual views                  |
| `-DKokkos_ENABLE_DEPRECATED_CODE=ON`             | Enable deprecated code                     |
| `-DKokkos_ENABLE_LARGE_MEM_TESTS=ON`             | Perform extra large memory tests           |

</details>

<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> For more, see https://kokkos.org/kokkos-core-wiki/keywords.html
<!--#endif-->

### Architecture-specific options

#### Host architectures

Host options are used for controlling optimization and are optional.

| Option                    | Architecture |
|---------------------------|--------------|
| `-DKokkos_ARCH_NATIVE=ON` | Local host   |

<!--#ifndef PRINT-->

<details>
<summary>

##### AMD CPU architectures

</summary>

| Option                  | Architecture |
|-------------------------|--------------|
| `-DKokkos_ARCH_ZEN3=ON` | Zen3         |
| `-DKokkos_ARCH_ZEN2=ON` | Zen2         |
| `-DKokkos_ARCH_ZEN=ON`  | Zen          |

</details>

<details>
<summary>

##### ARM CPU architectures

</summary>

| Option                    | Architecture             |
|---------------------------|--------------------------|
| `-DKokkos_ARCH_A64FX=ON`  | ARMv8.2 with SVE Support |
| `-DKokkos_ARCH_ARMV81=ON` | ARMV8.1                  |
| `-DKokkos_ARCH_ARMV80=ON` | ARMV8.0                  |

</details>

<details>
<summary>

##### Intel CPU architectures

</summary>

| Option                | Architecture          |
|-----------------------|-----------------------|
| `-DKokkos_ARCH_SPR=ON | Sapphire Rapids       |
| `-DKokkos_ARCH_SKX=ON | Skylake               |
| `-DKokkos_ARCH_BDW=ON | Intel Broadwell       |
| `-DKokkos_ARCH_HSW=ON | Intel Haswell         |
| `-DKokkos_ARCH_KNL=ON | Intel Knights Landing |
| `-DKokkos_ARCH_SNB=ON | Sandy Bridge          |

</details>

<!--#endif-->

#### Device architectures

Device options are mandatory.
They can be deduced from the device if present at CMake configuration time.

<details>
<summary>

##### AMD GPU architectures (HIP)

</summary>

| Option                         | Architecture | Associated cards     |
|--------------------------------|--------------|----------------------|
| `-DKokkos_ARCH_AMD_GFX942=ON`  | GFX942       | MI300A, MI300X       |
| `-DKokkos_ARCH_AMD_GFX90A=ON`  | GFX90A       | MI210, MI250, MI250X |
| `-DKokkos_ARCH_AMD_GFX908=ON`  | GFX908       | MI100                |
| `-DKokkos_ARCH_AMD_GFX906=ON`  | GFX906       | MI50, MI60           |
| `-DKokkos_ARCH_AMD_GFX1100=ON` | GFX1100      | 7900xt               |
| `-DKokkos_ARCH_AMD_GFX1030=ON` | GFX1030      | V620, W6800          |

<!--#ifndef PRINT-->

| Option                                                  | Description                                                                                   |
|---------------------------------------------------------|-----------------------------------------------------------------------------------------------|
| `-DKokkos_ENABLE_HIP_MULTIPLE_KERNEL_INSTANTIATIONS=ON` | Instantiate multiple kernels at compile time, improves performance but increases compile time |
| `-DKokkos_ENABLE_HIP_RELOCATABLE_DEVICE_CODE=ON`        | Enable Relocatable Device Code (RDC) for HIP                                                  |

<!--#endif-->

</details>

<details>
<summary>

##### Intel GPU architectures (SYCL)

</summary>

| Option                         | Architecture          |
|--------------------------------|-----------------------|
| `-DKokkos_ARCH_INTEL_GEN=ON`   | Generic JIT           |
| `-DKokkos_ARCH_INTEL_XEHP=ON`  | Xe-HP                 |
| `-DKokkos_ARCH_INTEL_PVC=ON`   | GPU Max/Ponte Vecchio |
| `-DKokkos_ARCH_INTEL_DG1=ON`   | Iris XeMAX            |
| `-DKokkos_ARCH_INTEL_GEN12=ON` | Gen12                 |
| `-DKokkos_ARCH_INTEL_GEN11=ON` | Gen11                 |

</details>

<details>
<summary>

##### NVIDIA GPU architectures (CUDA)

</summary>

| Option                       | Architecture | CC  | Associated cards                                       |
|------------------------------|--------------|-----|--------------------------------------------------------|
| `-DKokkos_ARCH_HOPPER90=ON`  | Hopper       | 9.0 | H200, H100                                             |
| `-DKokkos_ARCH_ADA89=ON`     | Ada          | 8.9 | GeForce RTX 40 series, RTX 6000/5000 series, L4, L40   |
| `-DKokkos_ARCH_AMPERE86=ON`  | Ampere       | 8.6 | GeForce RTX 30 series, RTX A series, A40, A10, A16, A2 |
| `-DKokkos_ARCH_AMPERE80=ON`  | Ampere       | 8.0 | A100, A30                                              |
| `-DKokkos_ARCH_TURING75=ON`  | Turing       | 7.5 | T4                                                     |
| `-DKokkos_ARCH_VOLTA72=ON`   | Volta        | 7.2 |                                                        |
| `-DKokkos_ARCH_VOLTA70=ON`   | Volta        | 7.0 | V100                                                   |
| `-DKokkos_ARCH_PASCAL61=ON`  | Pascal       | 6.1 | P6, P40, P4                                            |
| `-DKokkos_ARCH_PASCAL60=ON`  | Pascal       | 6.0 | P100                                                   |
| `-DKokkos_ARCH_MAXWELL53=ON` | Maxwell      | 5.3 |                                                        |
| `-DKokkos_ARCH_MAXWELL52=ON` | Maxwell      | 5.2 | M6, M60, M4, M40                                       |
| `-DKokkos_ARCH_MAXWELL50=ON` | Maxwell      | 5.0 | M10                                                    |
| `-DKokkos_ARCH_KEPLER37=ON`  | Kepler       | 3.7 | K80                                                    |
| `-DKokkos_ARCH_KEPLER35=ON`  | Kepler       | 3.5 | K40, K20                                               |
| `-DKokkos_ARCH_KEPLER32=ON`  | Kepler       | 3.2 |                                                        |
| `-DKokkos_ARCH_KEPLER30=ON`  | Kepler       | 3.0 | K10                                                    |

<!--#ifndef PRINT-->

<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> See NVIDIA documentation on Compute Capability (CC): https://developer.nvidia.com/cuda-gpus

| Option                                         | Description                                       |
|------------------------------------------------|---------------------------------------------------|
| `-DKokkos_ENABLE_CUDA_CONSTEXPR`               | Activate experimental relaxed constexpr functions |
| `-DKokkos_ENABLE_CUDA_LAMBDA`                  | Activate experimental lambda features             |
| `-DKokkos_ENABLE_CUDA_LDG_INTRINSIC`           | Use CUDA LDG intrinsics                           |
| `-DKokkos_ENABLE_CUDA_RELOCATABLE_DEVICE_CODE` | Enable relocatable device code (RDC) for CUDA     |

<!--#endif-->

</details>


<!--#ifndef PRINT-->
### Third-party Libraries (TPLs)

<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25">  See https://kokkos.org/kokkos-core-wiki/keywords.html#third-party-libraries-tpls
<!--#endif-->

### Examples for the most common architectures

#### Current CPU with OpenMP

```sh
cmake \
    -B build \
    -DCMAKE_BUILD_TYPE=Release \
    -DKokkos_ARCH_NATIVE=ON \
    -DKokkos_ENABLE_OPENMP=ON
```

#### AMD MI250 GPU with HIP and OpenMP

```sh
cmake \
    -B build \
    -DCMAKE_CXX_COMPILER=hipcc \
    -DCMAKE_BUILD_TYPE=Release \
    -DKokkos_ENABLE_HIP=ON \
    -DKokkos_ARCH_AMD_GFX90A=ON \
    -DKokkos_ENABLE_OPENMP=ON
```

#### NVIDIA A100 GPU with CUDA and OpenMP

```sh
cmake \
    -B build \
    -DCMAKE_BUILD_TYPE=Release \
    -DKokkos_ENABLE_CUDA=ON \
    -DKokkos_ARCH_AMPERE80=ON \
    -DKokkos_ENABLE_OPENMP=ON
```

#### NVIDIA V100 GPU with CUDA and OpenMP

```sh
cmake \
    -B build \
    -DCMAKE_BUILD_TYPE=Release \
    -DKokkos_ENABLE_CUDA=ON \
    -DKokkos_ARCH_VOLTA70=ON \
    -DKokkos_ENABLE_OPENMP=ON
```

#### Intel GPU Max/Ponte Vecchio GPU with SYCL and OpenMP

```sh
cmake \
    -B build \
    -DCMAKE_CXX_COMPILER=icpx \
    -DCMAKE_BUILD_TYPE=Release \
    -DKokkos_ENABLE_SYCL=ON \
    -DKokkos_ARCH_INTEL_PVC=ON \
    -DKokkos_ENABLE_OPENMP=ON \
    -DCMAKE_CXX_FLAGS="-fp-model=precise"  # for math precision
```

<!--#ifndef PRINT-->
<img title="Code" alt="Code" src="./images/code_txt.svg" height="25"> For more code examples:

- https://github.com/kokkos/kokkos/tree/master/example/build_cmake_installed
- https://github.com/kokkos/kokkos/tree/master/example/build_cmake_installed_different_compiler
<!--#endif-->
