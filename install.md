# Kokkos install cheat sheet

1. [Requirements](#requirements)
	1. [Compiler](#compiler)
	2. [Build system](#build-system)
2. [Build](#build)
	1. [Inline build](#inline-build)
	2. [Installed package](#installed-package)
		1. [Configure, build and install Kokkos](#configure-build-and-install-kokkos)
		2. [Configure your code](#configure-your-code)
		3. [Select options](#select-options)
			1. [CPU backends](#cpu-backends)
			2. [GPU backends](#gpu-backends)
			3. [Specific options](#specific-options)
			4. [Architecture-specific options](#architecture-specific-options)
		4. [Command examples for the latest architectures](#command-examples-for-the-latest-architectures)
		5. [Third-party Libraries (TPLs)](#third-party-libraries-tpls)
	3. [Spack](#spack)

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

## Build

### Inline build

Kokkos is built as part of the application.

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

### Installed package

Kokkos is built as a separate package and installed.

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

##### CPU backends

| Option                       | Backend | Notes          |
|------------------------------|---------|----------------|
| `-DKokkos_ENABLE_SERIAL=ON`  | Serial  | `ON`by default |
| `-DKokkos_ENABLE_OPENMP=ON`  | OpenMP  |                |
| `-DKokkos_ENABLE_PTHREAD=ON` | PThread |                |

##### GPU backends

| Option                            | Backend            | Notes        | Extra steps                                                                |
|-----------------------------------|--------------------|--------------|----------------------------------------------------------------------------|
| `-DKokkos_ENABLE_CUDA=ON`         | CUDA               |              | See NVIDIA [architecture-specific options](#architecture-specific-options) |
| `-DKokkos_ENABLE_HIP=ON`          | HIP                |              | See AMD [architecture-specific options](#architecture-specific-options)    |
| `-DKokkos_ENABLE_SYCL=ON`         | SYCL               | Experimental | See Intel [architecture-specific options](#architecture-specific-options)  |
| `-DKokkos_ENABLE_OPENMPTARGET=ON` | OpenMP with target | Experimental |                                                                            |
| `-DKokkos_ENABLE_HPX=ON`          | HPX                | Experimental |                                                                            |

<img title="Warning" alt="Warning" src="./images/warning.png" height="15"> You can only select `SERIAL`, one CPU backend and one GPU backend at a time.

##### Specific options

| Option                                        | Description                                                |
|-----------------------------------------------|------------------------------------------------------------|
| `-DKokkos_ENABLE_AGGRESSIVE_VECTORIZATION`    | Aggressively vectorize loops                               |
| `-DKokkos_ENABLE_COMPILER_WARNINGS`           | Print all compiler warnings                                |
| `-DKokkos_ENABLE_DEBUG_BOUNDS_CHECK`          | Use bounds checking - will increase runtime                |
| `-DKokkos_ENABLE_DEBUG_DUALVIEW_MODIFY_CHECK` | Debug check on dual views                                  |
| `-DKokkos_ENABLE_DEBUG`                       | Activate extra debug features - may increase compile times |
| `-DKokkos_ENABLE_DEPRECATED_CODE`             | Enable deprecated code                                     |
| `-DKokkos_ENABLE_EXAMPLES`                    | Enable building examples                                   |
| `-DKokkos_ENABLE_LARGE_MEM_TESTS`             | Perform extra large memory tests                           |
| `-DKokkos_ENABLE_TESTS`                       | Enable building tests                                      |
| `-DKokkos_ENABLE_TUNING`                      | Create bindings for tuning tools                           |

##### Architecture-specific options

<details>
<summary>All architectures</summary>

| Option                 | Description                             |
|------------------------|-----------------------------------------|
| `-DKokkos_ARCH_NATIVE` | Optimize for the local CPU architecture |

</details>

<details>
<summary>AMD CPU architectures</summary>

| Option                 | Description                      |
|------------------------|----------------------------------|
| `-DKokkos_ARCH_AMDAVX` | Optimize for AMDAVX architecture |
| `-DKokkos_ARCH_ZEN`    | Optimize for Zen architecture    |
| `-DKokkos_ARCH_ZEN2`   | Optimize for Zen2 architecture   |
| `-DKokkos_ARCH_ZEN3`   | Optimize for Zen3 architecture   |

</details>

<details>
<summary>ARM CPU architectures</summary>

| Option                          | Description                                   |
|---------------------------------|-----------------------------------------------|
| `-DKokkos_ARCH_A64FX`           | Optimize for ARMv8.2 with SVE Support         |
| `-DKokkos_ARCH_ARMV80`          | Optimize for ARMV80 architecture              |
| `-DKokkos_ARCH_ARMV81`          | Optimize for ARMV81 architecture              |
| `-DKokkos_ARCH_ARMV8_THUNDERX`  | Optimize for ARMV8_THUNDERX architecture      |
| `-DKokkos_ARCH_ARMV8_THUNDERX2` | Optimize for the ARMV8_THUNDERX2 architecture |

</details>

<details>
<summary>IBM CPU architectures</summary>

| Option                 | Description                               |
|------------------------|-------------------------------------------|
| `-DKokkos_ARCH_BGQ`    | Optimize for IBM Blue Gene Q architecture |
| `-DKokkos_ARCH_POWER7` | Optimize for IBM POWER7 architecture      |
| `-DKokkos_ARCH_POWER8` | Optimize for IBM POWER8 architecture      |
| `-DKokkos_ARCH_POWER9` | Optimize for IBM POWER9 architecture      |

</details>

<details>
<summary>Intel CPU architectures</summary>

| Option                      | Description                                               |
|-----------------------------|-----------------------------------------------------------|
| `-DKokkos_ARCH_BDW`         | Optimize for Intel Broadwell processor architecture       |
| `-DKokkos_ARCH_HSW`         | Optimize for Intel Haswell processor architecture         |
| `-DKokkos_ARCH_KNL`         | Optimize for Intel Knights Landing processor architecture |
| `-DKokkos_ARCH_KNC`         | Optimize for Intel Knights Corner processor architecture  |
| `-DKokkos_ARCH_INTEL_GEN`   | Optimize for Intel GPUs, Just-In-Time compilation         |
| `-DKokkos_ARCH_INTEL_DG1`   | Optimize for Intel Iris XeMAX GPU                         |
| `-DKokkos_ARCH_INTEL_GEN9`  | Optimize for Intel GPU Gen9                               |
| `-DKokkos_ARCH_INTEL_GEN11` | Optimize for Intel GPU Gen11                              |
| `-DKokkos_ARCH_INTEL_GEN12` | Optimize for Intel GPU Gen12                              |
| `-DKokkos_ARCH_SKX`         | Optimize for Skylake architecture                         |
| `-DKokkos_ARCH_SNB`         | Optimize for Sandy Bridge architecture                    |
| `-DKokkos_ARCH_SPR`         | Optimize for Sapphire Rapids architecture                 |
| `-DKokkos_ARCH_WSM`         | Optimize for Westmere architecture                        |

</details>

<details>
<summary>AMD GPU architectures (HIP)</summary>

| Option                      | Description                              | Associated cards     |
|-----------------------------|------------------------------------------|----------------------|
| `-DKokkos_ARCH_AMD_GFX906`  | Optimize for AMD GPU MI50/MI60 GFX906    | MI50/MI60            |
| `-DKokkos_ARCH_AMD_GFX908`  | Optimize for AMD GPU MI100 GFX908        | MI100                |
| `-DKokkos_ARCH_AMD_GFX90A`  | Optimize for AMD GPU MI200 series GFX90A | MI210, MI250, MI250X |
| `-DKokkos_ARCH_AMD_GFX1030` | Optimize for AMD GPU V620/W6800 GFX1030  | V620, W6800          |
| `-DKokkos_ARCH_AMD_GFX1100` | Optimize for AMD GPU 7900xt GFX1100      | 7900xt               |

| Option                                               | Description                                                                                  |
|------------------------------------------------------|----------------------------------------------------------------------------------------------|
| `-DKokkos_ENABLE_HIP_MULTIPLE_KERNEL_INSTANTIATIONS` | Instantiate multiple kernels at compile time - improve performance but increase compile time |
| `-DKokkos_ENABLE_HIP_RELOCATABLE_DEVICE_CODE`        | Enable relocatable device code (RDC) for HIP                                                 |

</details>

<details>
<summary>Intel GPU architectures (SYCL)</summary>

| Option                     | Description                                  |
|----------------------------|----------------------------------------------|
| `-DKokkos_ARCH_INTEL_GEN`  | Optimize for generic Intel GPUs              |
| `-DKokkos_ARCH_INTEL_XEHP` | Optimize for Intel GPU Xe-HP                 |
| `-DKokkos_ARCH_INTEL_PVC`  | Optimize for Intel GPU Ponte Vecchio/GPU Max |

</details>

<details>
<summary>NVIDIA GPU architectures (CUDA)</summary>

| Option                    | Description                                       | Associated cards |
|---------------------------|---------------------------------------------------|------------------|
| `-DKokkos_ARCH_AMPERE90`  | Optimize for the NVIDIA Ampere generation CC 9.0  |                  |
| `-DKokkos_ARCH_ADA89`     | Optimize for the NVIDIA Ada generation CC 8.9     |                  |
| `-DKokkos_ARCH_AMPERE80`  | Optimize for the NVIDIA Ampere generation CC 8.0  | A100             |
| `-DKokkos_ARCH_AMPERE86`  | Optimize for the NVIDIA Ampere generation CC 8.6  |                  |
| `-DKokkos_ARCH_KEPLER32`  | Optimize for the NVIDIA Kepler generation CC 3.2  |                  |
| `-DKokkos_ARCH_KEPLER30`  | Optimize for the NVIDIA Kepler generation CC 3.0  |                  |
| `-DKokkos_ARCH_KEPLER35`  | Optimize for the NVIDIA Kepler generation CC 3.5  |                  |
| `-DKokkos_ARCH_KEPLER37`  | Optimize for the NVIDIA Kepler generation CC 3.7  |                  |
| `-DKokkos_ARCH_MAXWELL50` | Optimize for the NVIDIA Maxwell generation CC 5.0 |                  |
| `-DKokkos_ARCH_MAXWELL52` | Optimize for the NVIDIA Maxwell generation CC 5.2 |                  |
| `-DKokkos_ARCH_MAXWELL53` | Optimize for the NVIDIA Maxwell generation CC 5.3 |                  |
| `-DKokkos_ARCH_PASCAL60`  | Optimize for the NVIDIA Pascal generation CC 6.0  | P100             |
| `-DKokkos_ARCH_PASCAL61`  | Optimize for the NVIDIA Pascal generation CC 6.1  |                  |
| `-DKokkos_ARCH_TURING75`  | Optimize for the NVIDIA Turing generation CC 7.5  | T4               |
| `-DKokkos_ARCH_VOLTA70`   | Optimize for the NVIDIA Volta generation CC 7.0   | V100             |
| `-DKokkos_ARCH_VOLTA72`   | Optimize for the NVIDIA Volta generation CC 7.2   |                  |

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
cmake -B build -DKokkos_ENABLE_HIP=ON -DKokkos_ENABLE_OPENMP=ON -DKokkos_ARCH_AMD_GFX90A=ON
```

</details>

<details>
<summary>For NVIDIA A100 GPUs with CUDA and OpenMP support</summary>

```bash
cmake -B build -DKokkos_ENABLE_CUDA=ON -DKokkos_ARCH_AMPERE80=ON  -DKokkos_ENABLE_OPENMP=ON
```

</details>

<details>
<summary>For NVIDIA V100 GPUs with CUDA and OpenMP support</summary>

```bash
cmake -B build -DKokkos_ENABLE_CUDA=ON -DKokkos_ARCH_VOLTA70=ON  -DKokkos_ENABLE_OPENMP=ON
```

</details>

<details>
<summary>For Intel Ponte Vecchio (GPU Max) GPUs with SYCL and OpenMP support</summary>

```bash
cmake -B build -DKokkos_ENABLE_SYCL=ON -DKokkos_ARCH_INTEL_PVC=ON  -DKokkos_ENABLE_OPENMP=ON
```

</details>

<img title="Code" alt="Code" src="./images/code.png" height="20"> For more code examples:

- https://github.com/kokkos/kokkos/tree/master/example/build_cmake_installed
- https://github.com/kokkos/kokkos/tree/master/example/build_cmake_installed_different_compiler

#### Third-party Libraries (TPLs)

<img title="Doc" alt="Doc" src="./images/documentation.png" height="20"> See https://kokkos.org/kokkos-core-wiki/keywords.html#third-party-libraries-tpls

### Spack

Kokkos is built as a separate package and installed using Spack.

<img title="Doc" alt="Doc" src="./images/documentation.png" height="20"> See https://kokkos.org/kokkos-core-wiki/building.html#spack
