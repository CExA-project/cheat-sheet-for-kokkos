# KOKKOS Cheat Sheet

Kokkos Core implements a programming model in C++ for writing performance portable applications targeting all major HPC platforms. For that purpose it provides abstractions for both parallel execution of code and data management. Kokkos is designed to target complex node architectures with N-level memory hierarchies and multiple types of execution resources. It currently can use CUDA, HIP, SYCL, HPX, OpenMP and C++ threads as backend programming models with several other backends development.

<img title="Warning" alt="Warning" src="./images/warning.png" height="15"> Only for Kokkos 4.2 and more, for older verison look at the doc.

Links:

- Full documentation: https://kokkos.org/kokkos-core-wiki/index.html
- GitHub sources: https://github.com/kokkos
- Tutorials: https://github.com/kokkos/kokkos-tutorials
- Training lecture series: https://github.com/kokkos/kokkos-tutorials/tree/main/LectureSeries

## Table of Contents

- [Cheat Sheet](#cheat-sheet)
  - [Table of Contents](#table-of-contents)
  - [Installation](#installation)
  - [Initialization](#initialization)
    - [headers:](#headers)
    - [Initialize and finalize Kokkos:](#initialize-and-finalize-kokkos)
    - [Command-line arguments](#command-line-arguments)
    - [Initialization by struc](#initialization-by-struc)
  - [Memory Management](#memory-management)
    - [View, the multidimensional array data container](#view-the-multidimensional-array-data-container)
      - [Creating a View](#creating-a-view)
      - [Accessing Elements](#accessing-elements)
      - [Managing Views](#managing-views)
    - [Memory Layouts](#memory-layouts)
    - [Memory Spaces](#memory-spaces)
      - [Generic Memory Space](#generic-memory-space)
      - [CUDA-specific Memory Spaces](#cuda-specific-memory-spaces)
      - [HIP-specific Memory Spaces](#hip-specific-memory-spaces)
      - [SYCL-specific Memory Spaces](#sycl-specific-memory-spaces)
      - [Unified Virtual Memory or Shared Space](#unified-virtual-memory-or-shared-space)
      - [Scratch Memory Spaces](#scratch-memory-spaces)
    - [View traits](#view-traits)
    - [View copy](#view-copy)
    - [HostMirror](#hostmirror)
    - [DualView](#dualview)
    - [Subview](#subview)
    - [ScatterView](#scatterview)
  - [Parallelism dispatch](#parallelism-dispatch)
    - [Parallel_for](#parallel_for)
    - [MDRange](#mdrange)
    - [Hierarchical Parallelism](#hierarchical-parallelism)
    - [Scratch Memory](#scratch-memory)
    - [Atomics](#atomics)

## Installation

<img title="Doc" alt="Doc" src="./images/documentation.png" height="20"> https://kokkos.org/kokkos-core-wiki/ProgrammingGuide/Compiling.html

<img title="Doc" alt="Doc" src="./images/documentation.png" height="20"> https://kokkos.org/kokkos-core-wiki/building.html

<img title="Doc" alt="Doc" src="./images/training.png" height="20"> https://github.com/kokkos/kokkos-tutorials/blob/main/LectureSeries/KokkosTutorial_01_Introduction.pdf

### Requirements

Minimum Compiler Versions:

- GCC: 5.3.0
- Clang: 4.0.0
- Clang: 10.0.0 (as CUDA compiler) 
- Intel: 17.0.1
- NVCC: 9.2.88
- NVC++: 21.5
- ROCM: 4.5
- MSVC: 19.29
- IBM XL: 16.1.1
- Fujitsu: 4.5.0
- ARM/Clang 20.1

Primary Tested Compilers:

- GCC: 5.3.0, 6.1.0, 7.3.0, 8.3, 9.2, 10.0
- NVCC: 9.2.88, 10.1, 11.0
- Clang: 8.0.0, 9.0.0, 10.0.0, 12.0.0
- Intel 17.4, 18.1, 19.5
- MSVC: 19.29
- ARM/Clang: 20.1
- IBM XL: 16.1.1
- ROCM: 4.5.0

Build system:

- CMake >= 3.16: required
- CMake >= 3.18: Fortran linkage. This does not affect most mixed Fortran/Kokkos builds. See build issues.
- CMake >= 3.21.1 for NVC++

<img title="Doc" alt="Doc" src="./images/documentation.png" height="20"> https://kokkos.org/kokkos-core-wiki/requirements.html

### Build

Kokkos developers propose 3 different ways to build Kokkos:

- Inline build: Kokkos is built as part of the application.
- Installed package: Kokkos is built as a separate package and installed.
- Spack package: Kokkos is built as a separate package and installed using Spack.

### Inline build

Use `add_subdirectory(kokkos)` with the Kokkos source and again just link with `target_link_libraries(Kokkos::kokkos)`.

<img title="Code" alt="Code" src="./images/code.png" height="20"> Code exmaple: 
- https://github.com/kokkos/kokkos/tree/master/example/build_cmake_in_tree

### Installed package
 
#### Default installation:

```bash
cmake <path to the Kokkos sources> \
 -DCMAKE_CXX_COMPILER=<your C++ compiler> \
 -DCMAKE_INSTALL_PREFIX=${kokkos_install_folder}
```

#### CPU backends:

- `-DKokkos_ENABLE_SERIAL=ON`: activate the SERIAL backend (`ON`by default)
- `-DKokkos_ENABLE_OPENMP=ON`: activate the OpenMP backend
- `-DKokkos_ENABLE_PTHREAD=ON`: activate the PTHREAD backend

#### GPU backends:

- `-DKokkos_ENABLE_CUDA=ON`: activate the CUDA backend
- `-DKokkos_ENABLE_HIP=ON`: activate the HIP backend
- `-DKokkos_ENABLE_SYCL=ON`: activate the SYCL backend (experimental)
- `-DKokkos_ENABLE_OPENMPTARGET=ON`: activate the OpenMP target backend (experimental)
- `-DKokkos_ENABLE_HPX=ON`: activate the HPX backend (experimental)

<img title="Warning" alt="Warning" src="./images/warning.png" height="15"> You can only select `SERIAL`, one CPU backend and one GPU backend at a time.

#### CMake compiling options:

| Option | Description | Default |
| ----------- | ----------- | -----|
| `Kokkos_ENABLE_AGGRESSIVE_VECTORIZATION` | Aggressively vectorize loops | OFF |
| `Kokkos_ENABLE_COMPILER_WARNINGS` | Print all compiler warnings | OFF |
| `Kokkos_ENABLE_CUDA_CONSTEXPR` | Activate experimental relaxed constexpr functions | OFF |
| `Kokkos_ENABLE_CUDA_LAMBDA` | Activate experimental lambda features | OFF |
| `Kokkos_ENABLE_CUDA_LDG_INTRINSIC` | Use CUDA LDG intrinsics | OFF |
| `Kokkos_ENABLE_CUDA_RELOCATABLE_DEVICE_CODE` | Enable relocatable device code (RDC) for CUDA | OFF |
| `Kokkos_ENABLE_DEBUG` | Activate extra debug features - may increase compile times | OFF |
| `Kokkos_ENABLE_DEBUG_BOUNDS_CHECK` | Use bounds checking - will increase runtime | OFF |Ò
| `Kokkos_ENABLE_DEBUG_DUALVIEW_MODIFY_CHECK` | Debug check on dual views | OFF |
| `Kokkos_ENABLE_DEPRECATED_CODE` | Enable deprecated code | OFF |
| `Kokkos_ENABLE_EXAMPLES` | Enable building examples | OFF |
| `Kokkos_ENABLE_HIP_MULTIPLE_KERNEL_INSTANTIATIONS` | Instantiate multiple kernels at compile time - improve performance but increase compile time | OFF |
| `Kokkos_ENABLE_HIP_RELOCATABLE_DEVICE_CODE` | Enable relocatable device code (RDC) for HIP | OFF |
| `Kokkos_ENABLE_LARGE_MEM_TESTS` | Perform extra large memory tests | OFF |
| `Kokkos_ENABLE_TESTS` | Enable building tests | OFF |
| `Kokkos_ENABLE_TUNING` | Create bindings for tuning tools | OFF |

#### Third-party Libraries (TPLs)

<img title="Doc" alt="Doc" src="./images/documentation.png" height="20"> See https://kokkos.org/kokkos-core-wiki/keywords.html#third-party-libraries-tpls

#### Architecture Optimization

- `Kokkos_ARCH_NATIVE=ON/OFF`: Optimize for the local CPU architecture

ARM-based architectures:

| Option             | Description                           | VALUES |
| ------------------ | ------------------------------------- | ------ |
| `Kokkos_ARCH_A64FX` | Optimize for ARMv8.2 with SVE Support | ON/OFF |
| `Kokkos_ARCH_ARMV80` | Optimize for ARMV80 architecture | ON/OFF |
| `Kokkos_ARCH_ARMV81` | Optimize for ARMV81 architecture | ON/OFF |
| `Kokkos_ARCH_ARMV8_THUNDERX` | Optimize for ARMV8_THUNDERX architecture | ON/OFF |
| `Kokkos_ARCH_ARMV8_THUNDERX2` | Optimize for the ARMV8_THUNDERX2 architecture | ON/OFF |

NVIDIA GPU architectures:

| Option | Description | GPU cards | VALUES |
| ----------- | ----------- | -----| ------ |
| `Kokkos_ARCH_AMPERE90` | Optimize for the NVIDIA Ampere generation CC 9.0 | | ON/OFF |
| `Kokkos_ARCH_ADA89` | Optimize for the NVIDIA Ada generation CC 8.9 | | ON/OFF |
| `Kokkos_ARCH_AMPERE80` | Optimize for the NVIDIA Ampere generation CC 8.0 | A100 | ON/OFF |
| `Kokkos_ARCH_AMPERE86` | Optimize for the NVIDIA Ampere generation CC 8.6 | | ON/OFF |
| `Kokkos_ARCH_KEPLER32` | Optimize for the NVIDIA Kepler generation CC 3.2 | | ON/OFF |
| `Kokkos_ARCH_KEPLER30` | Optimize for the NVIDIA Kepler generation CC 3.0 | | ON/OFF |
| `Kokkos_ARCH_KEPLER35` | Optimize for the NVIDIA Kepler generation CC 3.5 | | ON/OFF |
| `Kokkos_ARCH_KEPLER37` | Optimize for the NVIDIA Kepler generation CC 3.7 | | ON/OFF |
| `Kokkos_ARCH_MAXWELL50` | Optimize for the NVIDIA Maxwell generation CC 5.0 | | ON/OFF |
| `Kokkos_ARCH_MAXWELL52` | Optimize for the NVIDIA Maxwell generation CC 5.2 | | ON/OFF |
| `Kokkos_ARCH_MAXWELL53` | Optimize for the NVIDIA Maxwell generation CC 5.3 | | ON/OFF |
| `Kokkos_ARCH_PASCAL60` | Optimize for the NVIDIA Pascal generation CC 6.0 | | ON/OFF |
| `Kokkos_ARCH_PASCAL61` | Optimize for the NVIDIA Pascal generation CC 6.1 | | ON/OFF |
| `Kokkos_ARCH_TURING75` | Optimize for the NVIDIA Turing generation CC 7.5 | T4 | ON/OFF |
| `Kokkos_ARCH_VOLTA70` | Optimize for the NVIDIA Volta generation CC 7.0 | P100 | ON/OFF |
| `Kokkos_ARCH_VOLTA72` | Optimize for the NVIDIA Volta generation CC 7.2  | | ON/OFF |

AMD CPU architectures:

| Option | Description | VALUES |
| ----------- | ----------- | -----|
| `Kokkos_ARCH_AMDAVX` | Optimize for AMDAVX architecture | ON/OFF |
| `Kokkos_ARCH_ZEN` | Optimize for Zen architecture | ON/OFF |
| `Kokkos_ARCH_ZEN2` | Optimize for Zen2 architecture | ON/OFF |
| `Kokkos_ARCH_ZEN3` | Optimize for Zen3 architecture | ON/OFF |

AMD GPU architectures:

| Option | Description | GPU cards |VALUES |
| ----------- | ----------- | ----- | -----|
| `Kokkos_ARCH_AMD_GFX906` | Optimize for AMD GPU MI50/MI60 GFX906 | MI50/MI60 | ON/OFF |
| `Kokkos_ARCH_AMD_GFX908` | Optimize for AMD GPU MI100 GFX908 | MI100 | ON/OFF |
| `Kokkos_ARCH_AMD_GFX90A` | Optimize for AMD GPU MI200 series GFX90A | MI200 series: MI210, MI250, MI250X | ON/OFF |
| `Kokkos_ARCH_AMD_GFX1030` | Optimize for AMD GPU V620/W6800 GFX1030 | V620, W6800 | ON/OFF |
| `Kokkos_ARCH_AMD_GFX1100` | Optimize for AMD GPU 7900xt GFX1100 | 7900xt | ON/OFF |

Intel CPU architectures:

| Option | Description | VALUES |
| ----------- | ----------- | -----|
| `Kokkos_ARCH_BDW` | Optimize for Intel Broadwell processor architecture | ON/OFF |
| `Kokkos_ARCH_HSW` | Optimize for Intel Haswell processor architecture | ON/OFF |
| `Kokkos_ARCH_KNL` | Optimize for Intel Knights Landing processor architecture | ON/OFF |
| `Kokkos_ARCH_KNC` | Optimize for Intel Knights Corner processor architecture | ON/OFF |
| `Kokkos_ARCH_INTEL_GEN` | Optimize for Intel GPUs, Just-In-Time compilation | ON/OFF |
| `Kokkos_ARCH_INTEL_DG1` | Optimize for Intel Iris XeMAX GPU | ON/OFF |
| `Kokkos_ARCH_INTEL_GEN9` | Optimize for Intel GPU Gen9 | ON/OFF |
| `Kokkos_ARCH_INTEL_GEN11` | Optimize for Intel GPU Gen11 | ON/OFF |
| `Kokkos_ARCH_INTEL_GEN12` | Optimize for Intel GPU Gen12 | ON/OFF |
| `Kokkos_ARCH_SKX` | Optimize for Skylake architecture | ON/OFF |
| `Kokkos_ARCH_SNB` | Optimize for Sandy Bridge architecture | ON/OFF |
| `Kokkos_ARCH_SPR` | Optimize for Sapphire Rapids architecture | ON/OFF |
| `Kokkos_ARCH_WSM` | Optimize for Westmere architecture | ON/OFF |

Intel GPU architectures:

| Option | Description | VALUES |
| ----------- | ----------- | -----|
| `Kokkos_ARCH_INTEL_XEHP` | Optimize for Intel GPU Xe-HP | ON/OFF |
| `Kokkos_ARCH_INTEL_PVC` | Optimize for Intel GPU Ponte Vecchio/GPU Max | ON/OFF |

IBM CPU architectures:

| Option | Description | VALUES |
| ----------- | ----------- | -----|
| `Kokkos_ARCH_BGQ` | Optimize for IBM Blue Gene Q architecture | ON/OFF |
| `Kokkos_ARCH_POWER7` | Optimize for IBM POWER7 architecture | ON/OFF |
| `Kokkos_ARCH_POWER8` | Optimize for IBM POWER8 architecture | ON/OFF |
| `Kokkos_ARCH_POWER9` | Optimize for IBM POWER9 architecture | ON/OFF |

<img title="Doc" alt="Doc" src="./images/documentation.png" height="20"> For more, see https://kokkos.org/kokkos-core-wiki/keywords.html

#### Examples for the latest architectures:

For AMD MI250 GPUs with HIP and OpenMP support:

```bash
cmake . -DKokkos_ENABLE_HIP=ON -DKokkos_ENABLE_OPENMP=ON -DKokkos_ARCH_AMD_GFX90A=ON
```

For NVIDIA A100 GPUs with CUDA and OpenMP support:

```bash
cmake . -DKokkos_ENABLE_CUDA=ON -DKokkos_ARCH_AMPERE80=ON  -DKokkos_ENABLE_OPENMP=ON
```

For NVIDIA V100 GPUs with CUDA and OpenMP support:

```bash
cmake . -DKokkos_ENABLE_CUDA=ON -DKokkos_ARCH_VOLTA70=ON  -DKokkos_ENABLE_OPENMP=ON
```

For Intel Ponte Vecchio GPUs with SYCL and OpenMP support:

```bash
cmake . -DKokkos_ENABLE_SYCL=ON -DKokkos_ARCH_INTEL_PVC=ON  -DKokkos_ENABLE_OPENMP=ON
```

<img title="Code" alt="Code" src="./images/code.png" height="20"> For more code exmaples: 
- https://github.com/kokkos/kokkos/tree/master/example/build_cmake_installed
- https://github.com/kokkos/kokkos/tree/master/example/build_cmake_installed_different_compiler

### Spack

<img title="Doc" alt="Doc" src="./images/documentation.png" height="20"> See https://kokkos.org/kokkos-core-wiki/building.html#spack

## Initialization

### headers:

Headers:
```cpp
#include <Kokkos_Core.hpp>
#include <Kokkos_Kernel.hpp>
```

### Initialize and finalize Kokkos:

```cpp
Kokkos::initialize(int& argc, char* argv[]);
```

```cpp 
Kokkos::finalize();
```

### Command-line arguments

Command-line arguments can be passed to Kokkos::initialize() and are parsed by Kokkos and removed from the argument list.

- `-kokkos-help` / `–help`: print help message with the list of available options.

- `-kokkos-threads=INT` / `–threads=INT`: specify total number of threads or number of threads per NUMA region if used in conjunction with --numa option.

- `-kokkos-numa=INT` / `–numa=INT`: specify number of NUMA regions used by process.

- `-device-id=INT`: specify device id to be used by Kokkos.

- `-num-devices=INT[,INT]`: used when running MPI jobs. Specify the number of devices per node to be used. Process to device mapping happens by obtaining the local MPI rank and assigning devices round-robin. The optional second argument allows for an existing device to be ignored. This is most useful on workstations with multiple GPUs, one of which is used to drive screen output.

### Initialization by struc

```cpp
struct Kokkos::InitArguments {
  int num_threads;
  int num_numa;
  int device_id;
  int ndevices;
  int skip_device;
  bool disable_warnings;
};
```

```cpp
Kokkos::InitArguments args;
// 8 (CPU) threads per NUMA region
args.num_threads = 8;
// 2 (CPU) NUMA regions per process
args.num_numa = 2;
// If Kokkos was built with CUDA enabled, use the GPU with device ID 1.
args.device_id = 1;

Kokkos::initialize(args);
```

## Memory Management

### View, the multidimensional array data container

* A Kokkos View is a multidimensional array. It abstracts data containers and provides a consistent interface for data access across different memory spaces.
* Views are the primary data structure in Kokkos and can be used on both host and device.

#### Creating a View

Template parameters:
```cpp
Kokkos::View<DataType [, LayoutType] [, MemorySpace] [, MemoryTraits] viewName>;
```

- `DataType`: Defines the fundamental scalar type of the View and its dimensionality. The basic structure is `ScalarType*[]` where the number of `*` denotes the number of runtime length dimensions (dynamic allocation) and the number of `[]` defines the compile time dimensions (static). Due to C++ type restrictions runtime dimensions must come first.
- `LayoutType`: The layout of the view (optional).
- `MemorySpace`: The memory space where the view is allocated (optional). By default, the view is allocated in the default memory space of the execution space.
- `MemoryTraits`: The memory traits of the view (optional).

Constructors:

- Default constructor without allocation
```cpp
View()
```

- Default constructor with allocation
```cpp
View(const std::string &name, const IntType&... indices)
```

- Copy constructor with compatible view `rhs`
```cpp
View(const View<DataType>& rhs)
```

+ Example:
```cpp
// A 1D view of doubles
Kokkos::View<double*> view1D("view1D", 100);

// Const view of doubles
Kokkos::View<const double*> constView1D("constView1D", 100) = view1D;

// A 2D view of integers
Kokkos::View<int**> view2D("view2D", 50, 50);

// 3D view with 2 runtime dimensions and 1 compile time dimension
Kokkos::View<double**[25]> view3D("view3D", 50, 42, 25);
```

#### Accessing Elements

Data access is done using the parenthesis operator `()`.

```cpp
view1D(i) = 1.5 * i;
for(int j = 0; j < 50; ++j) {
    view2D(i, j) = i + j;
}
```

#### Managing Views

- `size()` returns the total number of elements in the view.
- `rank()` returns the number of dimensions.
- `extent()` returns the number of elements in each dimension.
- `layout()` returns the layout of the view.
- `resize()` Reallocates a view to have the new dimensions. Can grow or shrink, and will preserve content of the common subextents.
- `realloc()` Reallocates a view to have the new dimensions. Can grow or shrink, and will not preserve content.
- `data()` returns a pointer to the underlying data.

### Memory Layouts

Layout Determines the mapping of indices into the underlying 1D memory storage.

Views can have different memory layouts, like `Kokkos::LayoutLeft` (column-major) or `Kokkos::LayoutRight` (row-major).

- `LayoutRight()`: strides increase from the right most to the left most dimension (row-major or C-like).

- `LayoutLeft()`: strides increase from the left most to the right most dimension (column-major or Fortran-like).

- `LayoutStride()`: strides can be arbitrary for each dimension.

If no layout specified, default for that memory space is used.
`LayoutLeft` for CudaSpace, `LayoutRight` for HostSpace.
For performance, memory access patterns must result in
caching on a CPU and coalescing on a GPU.

```cpp
// 2D view with LayoutRight
Kokkos::View<double**, Kokkos::LayoutRight> view2D("view2D", 50, 50);
```

### Memory Spaces

The concept of a MemorySpace is the fundamental abstraction to represent the “where” and the “how” that memory allocation and access takes place in Kokkos.
Most code that uses Kokkos should be written to the generic concept of a MemorySpace rather than any specific instance.

<img title="Doc" alt="Doc" src="./images/documentation.png" height="20"> https://kokkos.org/kokkos-core-wiki/API/core/memory_spaces.html

#### Generic Memory Space

- `Kokkos::DefaultExecutionSpace::memory_space`

    The default memory space for the default execution space.
    This is the memory space used by Views when no memory space is specified.

- `Kokkos::DefaultHostExecutionSpace::memory_space`

    The default memory space for the default host execution space. If the code is compiled for CPU only, this is the same as `Kokkos::DefaultExecutionSpace::memory_space`.

- `Kokkos::HostSpace`

    The default memory space for data that resides on the host (CPU).
    Accessible from the host but not directly from the GPU.

```cpp
Kokkos::View<double*, Kokkos::HostSpace> hostView("hostView", size);
```

#### CUDA-specific Memory Spaces

<img title="Warning" alt="Warning" src="./images/warning.png" height="15"> These memory spaces are only available when compiling for the corresponding architecture.

- `Kokkos::CudaHostPinnedSpace`

    Used for data on the host that is pinned for efficient transfer to/from GPU.
    Allows for asynchronous data transfers between host and GPU.

```cpp
Kokkos::View<double*, Kokkos::CudaHostPinnedSpace> pinnedView("pinnedView", size);
```
   
- `Kokkos::CudaSpace`

    Default memory space for data that resides on an NVIDIA GPU.
    Accessible from the GPU but not from the host.

```cpp
Kokkos::View<double*, Kokkos::CudaSpace> gpuView("gpuView", size);
```

- `Kokkos::CudaUVMSpace`

    Unified Virtual Memory (UVM) space for NVIDIA GPUs.
    Data is accessible from both the host and the GPU, with a performance trade-off.

```cpp
Kokkos::View<double*, Kokkos::CudaUVMSpace> uvmView("uvmView", size);
```

#### HIP-specific Memory Spaces

<img title="Warning" alt="Warning" src="./images/warning.png" height="15"> These memory spaces are only available when compiling for the corresponding architecture.

- `Kokkos::HIPHostPinnedSpace`

    Used for data on the host that is pinned for efficient transfer to/from GPU.
    Allows for asynchronous data transfers between host and GPU.

```cpp
Kokkos::View<double*, Kokkos::HIPHostPinnedSpace> pinnedView("pinnedView", size);
```

- `Kokkos::HIPSpace`

    Default memory space for data that resides on an AMD GPU.
    Accessible from the GPU but not from the host.

```cpp
Kokkos::View<double*, Kokkos::HIPSpace> gpuView("gpuView", size);
```

- `Kokkos::HIPManagedSpace`

    Unified Virtual Memory (UVM) space for AMD GPUs.
    Data is accessible from both the host and the GPU, with a performance trade-off.

```cpp
Kokkos::View<double*, Kokkos::HIPUVMSpace> uvmView("uvmView", size);
```

#### SYCL-specific Memory Spaces

**Warning:** These memory spaces are only available when compiling for the corresponding architecture.

- `Kokkos::Experimental::SYCLDeviceUSMSpace`

- `Kokkos::Experimental::SYCLHostUSMSpace`

- `Kokkos::Experimental::SYCLSharedUSMSpace`

#### Unified Virtual Memory or Shared Space

`Kokkos::SharedSpace` is an Memory Space alias that represents memory that can be accessed by any enabled ExecutionSpace() type using the UVM concept.
The movement is done automatically by the OS and driver at the moment of access.
Performance depends on hardware and driver support.


```cpp
Kokkos::View<double*, Kokkos::SharedSpace> sharedView("sharedView", size);
```

#### Scratch Memory Spaces

- `Kokkos::ScratchMemorySpace`

    Used for temporary data within parallel constructs, like inside a kernel.
    Allocated per thread or per team of threads and is not visible outside.

```cpp

Kokkos::parallel_for(Kokkos::TeamPolicy<>(numTeams, teamSize), KOKKOS_LAMBDA(const Kokkos::TeamPolicy<>::member_type& team) {
    // Allocate scratch memory for each team
    Kokkos::View<double*, Kokkos::ScratchMemorySpace> scratchView(team.team_scratch(1), scratchSize);
});
```

### View traits

Traits Sets access properties via enum parameters for the templated Kokkos::MemoryTraits<> class:

- `Unmanaged`: The View will not be reference counted. The allocation has to be provided to the constructor.

```cpp
// Example of unmanaged view on CPU
double* data = new double[size];
Kokkos::View<double*, Kokkos::Unmanaged> unmanagedView(data, size);

// Example of unmanaged view on GPU using CUDA
double* data;
cudaMalloc(&data, size * sizeof(double));
Kokkos::View<double*, Kokkos::Unmanaged, Kokkos::CudaSpace> unmanagedView(data, size);
```

- `Atomic`: All accesses to the view will use atomic operations.

```cpp
Kokkos::View<double*, Kokkos::Atomic> atomicView("atomicView", size);
``` 

- `RandomAccess`: Hint that the view is used in a random access manner. If the view is also const this will trigger special load operations on GPUs (i.e. texture fetches).
On CUDA, this will use texture memory.

```cpp
const size_t N0 = ...;
Kokkos::View<int*> a_nonconst ("a", N0); // allocate nonconst View
// Assign to const, RandomAccess View
Kokkos::View<const int*, Kokkos::MemoryTraits<Kokkos::RandomAccess>> a_ra = a_nonconst;
```

- `Restrict`: There is no aliasing of the view by other data structures in the current scope.

Memory traits can be combined using the `Kokkos::MemoryTraits<>` class and `|`.

```cpp
// Example of unmanaged, atomic, random access view on GPU using CUDA
double* data;
cudaMalloc(&data, size * sizeof(double));
Kokkos::View<double*,  Kokkos::CudaSpace, Kokkos::MemoryTraits<Kokkos::Unmanaged | Kokkos::Atomic | Kokkos::RandomAccess>> unmanagedView(data, size);
```

### View copy

Kokkos automatically manages deallocation of Views through a reference-counting mechanism.
Copying or assigning a View does a shallow copy, and changes the reference count.

```cpp
Kokkos::View<int*> a ("a", 10);
Kokkos::View<int*> b ("b", 10);
a = b; // assignment does shallow copy
```

- `deep_copy(dest, src)`: Copies data from `src` view to `dest` view. The views must have the same dimensions, data type and reside in the same memory space.

```cpp
Kokkos::View<double*> view1("view1", size);
Kokkos::View<double*> view2("view2", size);

// Hard copy of view1 to view2
Kokkos::deep_copy(view2, view1);
```

<img title="Doc" alt="Doc" src="./images/documentation.png" height="20"> https://kokkos.org/kokkos-core-wiki/API/core/view/deep_copy.html

Code examples:
- [Kokkos example - simple memoryspace](https://github.com/kokkos/kokkos/blob/master/example/tutorial/04_simple_memoryspaces/simple_memoryspaces.cpp)
- [Kokkos example - overlapping deepcopy](https://github.com/kokkos/kokkos/blob/master/example/tutorial/Advanced_Views/07_Overlapping_DeepCopy/overlapping_deepcopy.cpp)
- [Kokkos Tutorials - Exercise 3](https://github.com/kokkos/kokkos-tutorials/blob/main/Exercises/03/Solution/exercise_3_solution.cpp)

### HostMirror

A `HostMirror` view is a view that is allocated in the host memory space as a mirror of a device view.
There is a `create_mirror` and `create_mirror_view` function which allocate views of the HostMirror type of view.

- `Kokkos::create_mirror()` : Creates a host mirror view of a device view and always allocate a new view

```cpp
typedef Kokkos :: View < double * , Space > ViewType ;
ViewType view (...);

ViewType::HostMirror hostView = Kokkos::create_mirror( view );
```

- `Kokkos::create_mirror_view()`: Creates a host mirror view of a device view but will only create a new view if the original one is not in HostSpace

```cpp
typedef Kokkos :: View < double * , Space > ViewType ;
ViewType view (...);

ViewType::HostMirror hostView = Kokkos::create_mirror_view( view );
```

Deep copy between hostView’s array to or from view’s array can be achieved using `Kokkos::deepcopy()`.

```cpp 
// From host to device
Kokkos::deepcopy(view, hostView );

// From device to host
Kokkos::deepcopy(hostView , view );
```

<img title="Doc" alt="Doc" src="./images/documentation.png" height="20"> https://kokkos.org/kokkos-core-wiki/API/core/view/create_mirror.html

Code examples:
- [Kokkos example - simple memoryspace](https://github.com/kokkos/kokkos/blob/master/example/tutorial/04_simple_memoryspaces/simple_memoryspaces.cpp)
- [Kokkos Tutorials - Exercise 3](https://github.com/kokkos/kokkos-tutorials/blob/main/Exercises/03/Solution/exercise_3_solution.cpp)

### DualView

+ DualView Concept: DualView in Kokkos provides two views: one for the host (`h_view`) and one for the device (`d_view`). You can operate on these views independently and synchronize them when necessary.

+ Synchronization: DualView has methods for synchronizing data between host and device: `sync_to_host()` and `sync_to_device()`. These ensure that the most recent data is available on the host or device before you begin operations there.

+ Modifiers: DualView uses modifiers to indicate the most recent data location (`modified_host` or `modified_device`). This helps to minimize unnecessary data transfers.

+ Example: 
```cpp
int main(int argc, char* argv[]) {
  Kokkos::initialize(argc, argv);

  {
    // Create a DualView of size 10
    Kokkos::DualView<double*> a_dual("A", 10);

    // Modify the device view
    Kokkos::parallel_for("Initialize", Kokkos::RangePolicy<>(0,10), KOKKOS_LAMBDA(int i) {
      a_dual.d_view(i) = i;
    });

    // Mark device view as modified
    a_dual.modify_device();

    // Synchronize data from device to host
    a_dual.sync_host();

    // Access data on the host
    for (size_t i = 0; i < a_dual.extent(0); ++i) {
      std::cout << a_dual.h_view(i) << std::endl;
    }
  }

  Kokkos::finalize();
  return 0;
}
```

### Subview

A subview is a view that is a subset of another view that mimic the behavior of languages like Python or Fortran.

- `Kokkos::subview`: Function to take a subview of a View. Use ``Kokkos::ALL`` to specify all elements in a dimension. Use ``Kokkos::make_pair`` to specify a range of elements in a dimension.

```cpp
// Create a 2D view
Kokkos::View<double**> view2D("view2D", 50, 50);

// Create a subview of the first 10 rows
Kokkos::View<double**> subview2D = Kokkos::subview(view2D, Kokkos::ALL, Kokkos::make_pair(0, 10));
```

Another way of getting a subview is through the appropriate View constructor.
  
```cpp
// Create a 2D view
Kokkos::View<double**> view2D("view2D", 50, 50);

// Create a subview of the first 10 rows
Kokkos::View<double**> subview2D(view2D, Kokkos::ALL, Kokkos::make_pair(0, 10));
```

<img title="Warning" alt="Warning" src="./images/warning.png" height="15"> A subview has the same reference count as its parent View, so the parent View won’t be deallocated before all subviews go away.

<img title="Warning" alt="Warning" src="./images/warning.png" height="15"> Every subview is also a View. This means that you may take a subview of a subview.

Doc pages:
- https://kokkos.org/kokkos-core-wiki/ProgrammingGuide/Subviews.html
- https://kokkos.org/kokkos-core-wiki/API/core/view/subview.html

### ScatterView

**Experimental feature**

<img title="Warning" alt="Warning" src="./images/warning.png" height="15"> Need `#include<Kokkos_ScatterView.hpp>`

A `Kokkos::Experimental::ScatterView` is a view extension that wraps an existing view ain order to efficiently perform scatter operations.
Scatter operations potentially write to the same memory location from multiple threads.
ScatterView provides a mechanism to efficiently handle this situation by using atomics or grid duplication to update the underlying view.

```cpp
template <class DataType , class Layout , class Space , class Operation , int Duplication , int Contribution > class ScatterView;
```

- `DataType`: Defines the fundamental scalar type of the View and its dimensionality. The basic structure is `ScalarType*[]` where the number of `*` denotes the number of runtime length dimensions (dynamic allocation) and the number of `[]` defines the compile time dimensions (static). Due to C++ type restrictions runtime dimensions must come first.
- `Layout`: The layout of the view (optional). See [Views Layouts](memory-layouts).
- `Space`: The memory space where the view is allocated (optional).
- `Operation`: The operation to perform when scattering (optional). By default, the operation is `Kokkos::Experimental::ScatterSum`. Other operations are `Kokkos::ScatterProd`, `Kokkos::Experimental::ScatterMin` and `Kokkos::Experimental::ScatterMax`.
- `Duplication`: whether to duplicate the grid or not (optional). By default, the duplication is `Kokkos::Experimental::ScatterDuplicated`. Other options are `Kokkos::Experimental::ScatterNonDuplicated`.
- `Contribution`: whether to contribute to use atomics. By default, the contribution is `Kokkos::Experimental::ScatterAtomic`. Other options are `Kokkos::Experimental::ScatterNonAtomic`.

```cpp
#include<Kokkos_ScatterView.hpp>

...

// Compute histogram of values in view1D
KOKKOS_INLINE_FUNCTION int get_index(double pos) { ... }
KOKKOS_INLINE_FUNCTION double compute(double weight) { ... }

// List of elements to process
Kokkos::View<double*> positions("positions", 100);
Kokkos::View<double*> weight("weight", 100);

// Historgram of N bins
Kokkos::View<double*> histogram("bar", N);

Kokkos::Experimental::ScatterView<double*> scatter(histogram);
Kokkos::parallel_for(100, KOKKOS_LAMBDA(int i) {
    auto access = scatter.access();
    auto index = get_index(positions(i);
    auto contribution = compute(weight(i);
    access(index) += contribution;
});

// Copy results back to histogram
Kokkos::Experimental::contribute(results, scatter);
```

<img title="Doc" alt="Doc" src="./images/documentation.png" height="20"> https://kokkos.org/kokkos-core-wiki/API/containers/ScatterView.html

Related Tutorial: https://github.com/kokkos/kokkos-tutorials/blob/main/LectureSeries/KokkosTutorial_03_MDRangeMoreViews.pdf

Code examples:
- [Kokkos Tutorials - ScatterView](https://github.com/kokkos/kokkos-tutorials/tree/main/Exercises/scatter_view)

## Parallelism dispatch

### Parallel_for

+ Default
``` cpp
parallel_for ( " Label " ,
numberOfIntervals, // == RangePolicy < >(0 , numberOfIntervals)
[=] ( const int64_t i ) {
/* ... body ... */
});
```

+ Custom: 
``` cpp 
parallel_for ( " Label " ,
RangePolicy < ExecutionSpace >(0, numberOfIntervals) ,
[=] ( const int64_t i ) {
/* ... body ... */
});
```

### MDRange

MDRangePolicy is used to define a multi-dimensional range for parallel iteration.
Here is an exemple for two iterations: 

```cpp 
Kokkos::MDRangePolicy<Kokkos::Rank<2>> policy({0, 0}, {N, M});
```

### Scratch Memory

2 levels of Scratch Memory Space: 
- 0: limited size but fast.
- 1: Larger allocation but equivalent to high bandwidth memory in latency.

Useful when same member of a team read the same data multiple times.

```cpp 
TeamPolicy < ExecutionSpace > policy ( numberOfTeams , teamSize );

// Define a scratch memory view type
typedef View < double * , ExecutionSpace::scratch_memory_space, MemoryUnmanaged > ScratchPadView ;

// Compute how much scratch memory ( in bytes ) is needed
size_t bytes = ScratchPadView::shmem_size ( vectorSize );

// Tell the policy how much scratch memory is needed
int level = 0;

parallel_for ( policy.set_scratch_size ( level , PerTeam ( bytes )),
KOKKOS_LAMBDA ( const member_type & teamMember ) {

// Create a view from the pre - existing scratch memory
ScratchPadView scratch ( teamMember . team_scratch ( level ) ,
vectorSize );
});
```

Don't forget the use of team_barrier to prevent threads to use scratch before all threads are done loading

+ Example

```cpp 
operator ()( member_type teamMember ) {
Scra tchPadVi ew scratch (...);
parallel_for ( ThreadVectorRange ( teamMember , vectorSize ) ,
[=] ( int i ) {
scratch ( i ) = B ( element , i );
});
teamMember . teambarrier ( ) ;
parallel_for ( TeamThreadRange ( teamMember , numberOfQPs ) ,
[=] ( int qp ) {
double total = 0;
for ( int i = 0; i < vectorSize ; ++ i ) {
total += A ( element , qp , i ) * scratch ( i );
}
result ( element , qp ) = total ;
});
}
```

### Atomics

In Kokkos, atomic operations are essential for ensuring data consistency in parallel computing environments.
They are particularly useful when multiple threads simultaneously update shared data.

+ Example

- atomic_add
```cpp
Kokkos::parallel_for (N , KOKKOS_LAMBDA ( const size_t index ) {
	const Something value = ...;
	const int bucketIndex = computeBucketIndex ( value );
	Kokkos :: atomic_add (& _histogram ( bucketIndex ) , 1);
});
```

- atomic_exchanges 

```cpp 
// Assign * dest to val , return former value of * dest
template < typename T >
T atomic_exchange ( T * dest , T val );

// If * dest == comp then assign * dest to val
// Return true if succeeds .
template < typename T >
bool atomic_compare_exchange_strong ( T * dest , T comp , T val );
```

## Hierarchical Parallelism

Kokkos supports hierarchical parallelism with the use of teams. Key commands include TeamPolicy to define teams, TeamThreadRange for team-level iteration, and parallel_for within a team.
+ Example

```cpp 
Kokkos::TeamPolicy team_policy(Number_Of_Teams, Team_Size); #We ususally take Team_Size = KOKKOS::AUTO
Kokkos::parallel_for(team_policy, KOKKOS_LAMBDA(const Kokkos::TeamPolicy::member_type& teamMember) {
  const int team_rank = teamMember.team_rank();
  Kokkos::TeamThreadRange(teamMember, vector_length, i) {
    // Parallel computation within a team
  }
});
```

## Macros