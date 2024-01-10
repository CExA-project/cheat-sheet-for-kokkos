# Cheat Sheet

## Memory

### View 

What is a Kokkos View?

* A Kokkos View is a multidimensional array or a tensor. It abstracts data containers and provides a consistent interface for data access across different memory spaces.
* Views are the primary data structure in Kokkos and can be used on both host and device.

Basic Usage
1. Creating a View

> Syntax: Kokkos::View<DataType> viewName("viewName", dimensions...);

+ Example:
```cpp
// A 1D view of doubles
Kokkos::View<double*> view1D("view1D", 100);

// A 2D view of integers
Kokkos::View<int**> view2D("view2D", 50, 50);
```

2. Accessing Elements

+ Use regular array indexing syntax.

``` cpp 
Kokkos::parallel_for(100, KOKKOS_LAMBDA(const int i) {
    view1D(i) = 1.5 * i;
    for(int j = 0; j < 50; ++j) {
        view2D(i, j) = i + j;
    }
});
```

### Different Memory Spaces to store Views on Kokkos

1. Host Memory Space

- Kokkos::HostSpace

    The default memory space for data that resides on the host (CPU).
    Accessible from the host but not directly from the GPU.

Example:

```cpp

Kokkos::View<double*, Kokkos::HostSpace> hostView("hostView", size);
```

- Kokkos::CudaHostPinnedSpace

    Used for data on the host that is pinned for efficient transfer to/from GPU.
    Allows for asynchronous data transfers between host and GPU.

Example:

```cpp

Kokkos::View<double*, Kokkos::CudaHostPinnedSpace> pinnedView("pinnedView", size);
```

2. GPU Memory Spaces
- Kokkos::CudaSpace

    Default memory space for data that resides on an NVIDIA GPU.
    Accessible from the GPU but not from the host.

Example:

```cpp

Kokkos::View<double*, Kokkos::CudaSpace> gpuView("gpuView", size);
```

- Kokkos::CudaUVMSpace

    Unified Virtual Memory (UVM) space for NVIDIA GPUs.
    Data is accessible from both the host and the GPU, with a performance trade-off.

Example:

```cpp

Kokkos::View<double*, Kokkos::CudaUVMSpace> uvmView("uvmView", size);
```

+ Shared Memory Space
- Kokkos::ScratchMemorySpace

    Used for temporary data within parallel constructs, like inside a kernel.
    Allocated per thread or per team of threads and is not visible outside.

Example:

```cpp

Kokkos::parallel_for(Kokkos::TeamPolicy<>(numTeams, teamSize), KOKKOS_LAMBDA(const Kokkos::TeamPolicy<>::member_type& team) {
    // Allocate scratch memory for each team
    Kokkos::View<double*, Kokkos::ScratchMemorySpace> scratchView(team.team_scratch(1), scratchSize);
});
```

### Views Layouts

Views can have different memory layouts, like Kokkos::LayoutLeft (column-major) or Kokkos::LayoutRight (row-major).

```cpp
View < double *** , Layout, Space > name (...);
```
If no layout specified, default for that memory space is used.
LayoutLeft for CudaSpace, LayoutRight for HostSpace.
For performance, memory access patterns must result in
caching on a CPU and coalescing on a GPU.

### DualView

Dualviews 

### Mirror

Mirrors are views of equivalent arrays residing in possibly different memory spaces.

1. Create a view’s array in some memory space.
```cpp
typedef Kokkos :: View < double * , Space > ViewType ;
ViewType view (...);
```
2. Create hostView, a mirror of the view’s array residing in the
host memory space.
``` cpp 
ViewType::HostMirror hostView =
Kokkos::createmirrorview( view );
```

3. Populate hostView on the host (from file, etc.).
4. Deep copy hostView’s array to view’s array.
```cpp 
Kokkos::deepcopy(view, hostView );
```
5. Launch a kernel processing the view’s array.
```cpp
Kokkos::parallel_for(" Label ",
RangePolicy <Space>(0 , size ) ,
KOKKOS_LAMBDA (...) { use and change view });
```

6. If needed, deep copy the view’s updated array back to the
hostView’s array to write file, etc.
```cpp
Kokkos :: deepcopy (hostView , view);
```

## Kernel

### Parallel_for

### MdRange

### Hierarchical Parallelism

### Task Parallelism

### Scratch Memory

### Atomics

### ScatterView
