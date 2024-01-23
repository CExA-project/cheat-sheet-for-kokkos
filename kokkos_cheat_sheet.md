# Cheat Sheet

Kokkos Core implements a programming model in C++ for writing performance portable applications targeting all major HPC platforms. For that purpose it provides abstractions for both parallel execution of code and data management. Kokkos is designed to target complex node architectures with N-level memory hierarchies and multiple types of execution resources. It currently can use CUDA, HIP, SYCL, HPX, OpenMP and C++ threads as backend programming models with several other backends development.

Links:

- Full documentation: https://kokkos.org/kokkos-core-wiki/index.html
- GitHub sources: https://github.com/kokkos
- Tutorials: https://github.com/kokkos/kokkos-tutorials

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

related doc page : https://kokkos.org/kokkos-core-wiki/API/core/memory_spaces.html

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

Doc page: https://kokkos.org/kokkos-core-wiki/API/core/view/deep_copy.html

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

Doc page: https://kokkos.org/kokkos-core-wiki/API/core/view/create_mirror.html

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

Doc page: https://kokkos.org/kokkos-core-wiki/API/containers/ScatterView.html

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

### Hierarchical Parallelism

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
