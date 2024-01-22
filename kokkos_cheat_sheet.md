# Cheat Sheet

Kokkos Core implements a programming model in C++ for writing performance portable applications targeting all major HPC platforms. For that purpose it provides abstractions for both parallel execution of code and data management. Kokkos is designed to target complex node architectures with N-level memory hierarchies and multiple types of execution resources. It currently can use CUDA, HIP, SYCL, HPX, OpenMP and C++ threads as backend programming models with several other backends development.

Full documentation : https://kokkos.org/kokkos-core-wiki/index.html

## Installation

## Memory Management

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

- `Kokkos::HostSpace`

    The default memory space for data that resides on the host (CPU).
    Accessible from the host but not directly from the GPU.

Example:

```cpp

Kokkos::View<double*, Kokkos::HostSpace> hostView("hostView", size);
```

- `Kokkos::CudaHostPinnedSpace`

    Used for data on the host that is pinned for efficient transfer to/from GPU.
    Allows for asynchronous data transfers between host and GPU.

Example:

```cpp

Kokkos::View<double*, Kokkos::CudaHostPinnedSpace> pinnedView("pinnedView", size);
```

2. GPU Memory Spaces
   
- `Kokkos::CudaSpace`

    Default memory space for data that resides on an NVIDIA GPU.
    Accessible from the GPU but not from the host.

Example:

```cpp

Kokkos::View<double*, Kokkos::CudaSpace> gpuView("gpuView", size);
```

- `Kokkos::CudaUVMSpace`

    Unified Virtual Memory (UVM) space for NVIDIA GPUs.
    Data is accessible from both the host and the GPU, with a performance trade-off.

Example:

```cpp

Kokkos::View<double*, Kokkos::CudaUVMSpace> uvmView("uvmView", size);
```

+ Shared Memory Space
- `Kokkos::ScratchMemorySpace`

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

Views can have different memory layouts, like `Kokkos::LayoutLeft` (column-major) or `Kokkos::LayoutRight` (row-major).

```cpp
View < double *** , Layout, Space > name (...);
```
If no layout specified, default for that memory space is used.
LayoutLeft for CudaSpace, LayoutRight for HostSpace.
For performance, memory access patterns must result in
caching on a CPU and coalescing on a GPU.

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

### ScatterView
