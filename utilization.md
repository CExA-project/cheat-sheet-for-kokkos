# Kokkos utilization cheat sheet

<img title="Warning" alt="Warning" src="./images/warning.png" height="15"> Only for Kokkos 4.2 and more, for older verison look at the doc.

1. [Initialization](#initialization)
	1. [Headers](#headers)
	2. [Initialize and finalize Kokkos](#initialize-and-finalize-kokkos)
		1. [Command-line arguments](#command-line-arguments)
		2. [Struct arguments](#struct-arguments)
3. [Memory management](#memory-management)
	1. [View](#view)
		1. [Creating a view](#creating-a-view)
		2. [Accessing elements](#accessing-elements)
		3. [Managing views](#managing-views)
	2. [Memory Layout](#memory-layout)
	3. [Memory space](#memory-space)
		1. [Generic memory space](#generic-memory-space)
		2. [CUDA-specific memory spaces](#cuda-specific-memory-spaces)
		3. [HIP-specific memory spaces](#hip-specific-memory-spaces)
		4. [SYCL-specific memory spaces](#sycl-specific-memory-spaces)
		5. [Unified virtual memory or shared space](#unified-virtual-memory-or-shared-space)
		6. [Scratch memory space](#scratch-memory-space)
	4. [Memory trait](#memory-trait)
	5. [View copy](#view-copy)
	6. [Mirror view](#mirror-view)
		1. [Create and allocate](#create-and-allocate)
		2. [Create and conditionally allocate](#create-and-conditionally-allocate)
		3. [Synchronize](#synchronize)
	7. [Dual view](#dual-view)
		1. [Create](#create)
		2. [Access data](#access-data)
			1. [Host view](#host-view)
			2. [Device view](#device-view)
		3. [Synchronize](#synchronize)
	8. [Subview](#subview)
		1. [Create](#create)
		2. [Create from view](#create-from-view)
	9. [ScatterView](#scatterview)
		1. [Create](#create)
			1. [Scatter operation](#scatter-operation)
2. [Parallelism patterns](#parallelism-patterns)
	1. [For loop](#for-loop)
	2. [Reduction](#reduction)
	3. [Fences](#fences)
3. [Execution policy](#execution-policy)
	1. [Ranges](#ranges)
		1. [One-dimensional range](#one-dimensional-range)
		2. [Multi-dimensional](#multi-dimensional)
	2. [Hierarchical parallelism](#hierarchical-parallelism)
		1. [Team policy](#team-policy)
		2. [Hierarchy structure](#hierarchy-structure)
			1. [Thread level or vector level](#thread-level-or-vector-level)
			2. [Thread and vector level](#thread-and-vector-level)
		3. [Range policy](#range-policy)
			1. [One-dimensional team thread range or team vector range](#one-dimensional-team-thread-range-or-team-vector-range)
			2. [Multi-dimensional team thread range or team vector range](#multi-dimensional-team-thread-range-or-team-vector-range)
			3. [One-dimensional team thread vector range](#one-dimensional-team-thread-vector-range)
			4. [Multi-dimensional team thread vector range](#multi-dimensional-team-thread-vector-range)
4. [Scratch memory](#scratch-memory)
	1. [Scratch memory space](#scratch-memory-space)
	2. [Create and populate](#create-and-populate)
5. [Atomics](#atomics)
	1. [Atomic operations](#atomic-operations)
	2. [Atomic exchanges](#atomic-exchanges)
6. [Macros](#macros)

## Initialization

### Headers

```cpp
#include <Kokkos_Core.hpp>
```

### Initialize and finalize Kokkos

```cpp
Kokkos::initialize(int& argc, char* argv[]);
{
    /* ... */
}
Kokkos::finalize();
```

#### Command-line arguments



Command-line arguments are parsed by `Kokkos::initialize` and removed from the argument list.

| Argument                 | Effect                                                                                                                                              |
|--------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `-kokkos-help`           | Print help message with the list of available options                                                                                               |
| `-kokkos-threads=INT`    | Specify total number of threads or number of threads per NUMA region if used in conjunction with `--kokkos-numa` option                             |
| `-kokkos-numa=INT`       | Specify number of NUMA regions used by process                                                                                                      |
| `-device-id=INT`         | Specify device ID to be used by Kokkos                                                                                                              |
| `-num-devices=INT[,INT]` | Specify the number of devices per node to be used when running MPI jobs; the optional second argument allows for an existing device to be ignored |

#### Struct arguments

```cpp
Kokkos::InitializationSettings args;
// 8 (CPU) threads per NUMA region
args.num_threads = 8;
// 2 (CPU) NUMA regions per process
args.num_numa = 2;
// If Kokkos was built with CUDA enabled, use the GPU with device ID 1.
args.device_id = 1;

Kokkos::initialize(args);
```

## Memory management

### View

Multidimensional array that abstracts data containers and provides a consistent interface for data access across different memory spaces, it is used on both host and device.

<img title="Doc" alt="Doc" src="./images/documentation.png" height="20"> https://kokkos.org/kokkos-core-wiki/API/core/view/view.html

#### Creating a view

```cpp
Kokkos::View<DataType, LayoutType, MemorySpace, MemoryTraits> view("label", numberOfElements);
```

| Template argument | Description                                                                                                                                                                                                                                                                                                  |
|-------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `DataType`        | Fundamental scalar type of the view and its dimensionality; syntax is `ScalarType*[]` where the number of `*` denotes the number of runtime length dimensions (dynamic allocation) and the number of `[]` defines the compile time dimensions (static allocation); runtime dimensions must come first |
| `LayoutType`      | [Memory layout](#memory-layout) of the view                                                                                                                                                                                                                                                                  |
| `MemorySpace`     | [Memory space](#memory-space) where the view is allocated, defaults to the memory space of the execution space                                                                                                                                                                                               |
| `MemoryTraits`    | [Memory trait](#memory-trait) of the view                                                                                                                                                                                                                                                                    |

<img title="Doc" alt="Doc" src="./images/documentation.png" height="20"> https://kokkos.org/kokkos-core-wiki/API/core/view/view.html#constructors

<details>
<summary>Examples</summary>

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

</details>

#### Accessing elements

```cpp
for (int i = 0; i < 10; i++) {
    for (int j = 0; j < 50; ++j) {
        view(i, j) = i + j;
    }
}
```

<img title="Doc" alt="Doc" src="./images/documentation.png" height="20"> https://kokkos.org/kokkos-core-wiki/API/core/view/view.html#data-access-functions

#### Managing views

| Method      | Description                                                                                                           |
|-------------|-----------------------------------------------------------------------------------------------------------------------|
| `size()`    | Returns the total number of elements in the view                                                                      |
| `rank()`    | Returns the number of dimensions                                                                                      |
| `extent()`  | Returns the number of elements in each dimension                                                                      |
| `layout()`  | Returns the layout of the view                                                                                        |
| `resize()`  | Reallocates a view to have the new dimensions; can grow or shrink, and will preserve content of the common subextents |
| `realloc()` | Reallocates a view to have the new dimensions; can grow or shrink, and will not preserve content                      |
| `data()`    | Returns a pointer to the underlying data                                                                              |

<img title="Doc" alt="Doc" src="./images/documentation.png" height="20"> https://kokkos.org/kokkos-core-wiki/API/core/view/view.html#data-layout-dimensions-strides

### Memory Layout

Layout Determines the mapping of indices into the underlying 1D memory storage:

| Layout                   | Description                                                     | Other name                   | Efficient for |
|--------------------------|-----------------------------------------------------------------|------------------------------|---------------|
| `Kokkos::LayoutRight()`  | Strides increase from the right most to the left most dimension | row-major or C-like          | CPU           |
| `Kokkos::LayoutLeft()`   | Strides increase from the left most to the right most dimension | column-major or Fortran-like | GPU           |
| `Kokkos::LayoutStride()` | Strides can arbitrary for each dimension                        |                              |               |

If no layouts are specified, the most efficient one for the memory space is used.
For performance, memory access patterns must result in caching on a CPU and coalescing on a GPU.

<img title="Doc" alt="Doc" src="./images/documentation.png" height="20"> https://kokkos.org/kokkos-core-wiki/API/core/view/view.html#data-layout-dimensions-strides

<details>
<summary>Example</summary>

```cpp
// 2D view with LayoutRight
Kokkos::View<double**, Kokkos::LayoutRight> view2D("view2D", 50, 50);
```

</details>

### Memory space

Abstraction to represent the “where” and the “how” the memory allocation and access takes place in Kokkos.
Most code should be written to the generic concept of a memory space rather than any specific instance.

<img title="Doc" alt="Doc" src="./images/documentation.png" height="20"> https://kokkos.org/kokkos-core-wiki/API/core/memory_spaces.html

#### Generic memory space

| Memory space                                      | Description                                                                                                                                          |
|---------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `Kokkos::DefaultExecutionSpace::memory_space`     | Default memory space of the default execution space, used by default                                                                                 |
| `Kokkos::DefaultHostExecutionSpace::memory_space` | Default memory space of the default host execution space; same as `Kokkos::DefaultExecutionSpace::memory_space` if the code is compiled for CPU only |
| `Kokkos::HostSpace`                               | Default memory space for data that resides on the host, accessible from the host but not directly from the GPU                                       |

<details>
<summary>Example</summary>

```cpp
Kokkos::View<double*, Kokkos::HostSpace> hostView("hostView", numberOfElements);
```

</details>

#### Unified virtual memory or shared space

| Memory space          | Description                                                                                                                                                                                                  |
|-----------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `Kokkos::SharedSpace` | Data that can be accessed by any enabled execution space using the UVM concept; the movement is done automatically by the driver at the moment of access, performance depends on hardware and driver support |

<details>
<summary>Example</summary>

```cpp
Kokkos::View<double*, Kokkos::SharedSpace> sharedView("sharedView", numberOfElements);
```

</details>

#### Scratch memory space

| Memory space                 | Description                                                                                                               |
|------------------------------|---------------------------------------------------------------------------------------------------------------------------|
| `Kokkos::ScratchMemorySpace` | Temporary data within parallel constructs which is allocated per thread or per team of threads and is not visible outside |

<details>
<summary>Example</summary>

```cpp
Kokkos::parallel_for(
    Kokkos::TeamPolicy<>(numberOfTeams, numberOfElementsPerTeam),
    KOKKOS_LAMBDA (const Kokkos::TeamPolicy<>::member_type& team) {
        // Allocate scratch memory for each team
        Kokkos::View<double*, Kokkos::ScratchMemorySpace> scratchView(team.team_scratch(1), scratchSize);
    }
);
```

</details>

### Memory trait

| Memory trait           | Description                                                                                                                                                       |
|------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `Kokkos::Unmanaged`    | The view will not be reference counted; the allocation has to be provided to the constructor                                                                      |
| `Kokkos::Atomic`       | All accesses to the view will use atomic operations                                                                                                               |
| `Kokkos::RandomAccess` | Hint that the view is used in a random access manner; if the view is also `const` this will trigger special load operations on GPUs (e.g. texture memory on CUDA) |
| `Kokkos::Restrict`     | There is no aliasing of the view by other data structures in the current scope                                                                                    |

Memory traits can be combined using the `Kokkos::MemoryTraits<>` class and `|`.

<img title="Doc" alt="Doc" src="./images/documentation.png" height="20"> https://kokkos.org/kokkos-core-wiki/ProgrammingGuide/View.html#access-traits

<details>
<summary>Examples</summary>

```cpp
// Unmanaged view on CPU
double* data = new double[numberOfElements];
Kokkos::View<double*, Kokkos::Unmanaged> unmanagedView(data, numberOfElements);

// Unmanaged view on GPU using CUDA
double* data;
cudaMalloc(&data, numberOfElements * sizeof(double));
Kokkos::View<double*, Kokkos::Unmanaged, Kokkos::CudaSpace> unmanagedView(data, numberOfElements);

// Atomic view
Kokkos::View<double*, Kokkos::Atomic> atomicView("atomicView", numberOfElements);

// Random access with constant data
// first, allocate non constant view
Kokkos::View<int*> nonConstView ("data", numberOfElements);
// then, make it constant
Kokkos::View<const int*, Kokkos::MemoryTraits<Kokkos::RandomAccess>> randomAccessView = nonConstView;

// Unmanaged, atomic, random access view on GPU using CUDA
double* data;
cudaMalloc(&data, numberOfElements* sizeof(double));
Kokkos::View<double*,  Kokkos::CudaSpace, Kokkos::MemoryTraits<Kokkos::Unmanaged | Kokkos::Atomic | Kokkos::RandomAccess>> unmanagedView(data, numberOfElements);
```

</details>

### View copy

<img title="Warning" alt="Warning" src="./images/warning.png" height="15"> Copying or assigning a view does a shallow copy, and just changes the reference count.
Data are not synchronized in this case.

```cpp
Kokkos::deep_copy(dest, src);
```

Copies data from `src` view to `dest` view.
The views must have the same dimensions, data type and reside in the same memory space ([mirror views](#mirror-view) can be deep copied on different memory spaces).

<img title="Doc" alt="Doc" src="./images/documentation.png" height="20"> https://kokkos.org/kokkos-core-wiki/API/core/view/deep_copy.html

<img title="Code" alt="Code" src="./images/code.png" height="20"> Code examples:
- [Kokkos example - simple memoryspace](https://github.com/kokkos/kokkos/blob/master/example/tutorial/04_simple_memoryspaces/simple_memoryspaces.cpp)
- [Kokkos example - overlapping deepcopy](https://github.com/kokkos/kokkos/blob/master/example/tutorial/Advanced_Views/07_Overlapping_DeepCopy/overlapping_deepcopy.cpp)
- [Kokkos Tutorials - Exercise 3](https://github.com/kokkos/kokkos-tutorials/blob/main/Exercises/03/Solution/exercise_3_solution.cpp)

<details>
<summary>Example</summary>

```cpp
Kokkos::View<double*> view1("view1", numberOfElements);
Kokkos::View<double*> view2("view2", numberOfElements);

// Hard copy of view1 to view2
Kokkos::deep_copy(view2, view1);
```

</details>

### Mirror view

A `HostMirror` view is allocated in the host memory space as a mirror of a device view.

<img title="Doc" alt="Doc" src="./images/documentation.png" height="20"> https://kokkos.org/kokkos-core-wiki/API/core/view/create_mirror.html

<img title="Code" alt="Code" src="./images/code.png" height="20"> Code examples:

- [Kokkos example - simple memoryspace](https://github.com/kokkos/kokkos/blob/master/example/tutorial/04_simple_memoryspaces/simple_memoryspaces.cpp)
- [Kokkos Tutorials - Exercise 3](https://github.com/kokkos/kokkos-tutorials/blob/main/Exercises/03/Solution/exercise_3_solution.cpp)

#### Create and allocate

```cpp
Kokkos::View<double*, Space> view(/* ... */);
Kokkos::View<double*, Space>::HostMirror hostView = Kokkos::create_mirror(view);
```

Create a host mirror view of a device view and always allocate data.

#### Create and conditionally allocate

```cpp
Kokkos::View<double*, Space> view(/* ... */);
Kokkos::View<double*, Space>::HostMirror hostView = Kokkos::create_mirror_view(view);
```

Create a host mirror view of a device view but only allocate data if the original one is not in the host space.

#### Synchronize

```cpp
// From host to device
Kokkos::deepcopy(view, hostView );

// From device to host
Kokkos::deepcopy(hostView, view );
```

### Subview

A `subview` is a `View` that is a subset of another view that mimics the behavior of languages like Python or Fortran.

<img title="Warning" alt="Warning" src="./images/warning.png" height="15"> A subview has the same reference count as its parent View, so the parent View won’t be deallocated before all subviews go away.

<img title="Warning" alt="Warning" src="./images/warning.png" height="15"> Every subview is also a view. This means that you may take a subview of a subview.

<img title="Doc" alt="Doc" src="./images/documentation.png" height="20"> https://kokkos.org/kokkos-core-wiki/API/core/view/subview.html

<img title="Doc" alt="Doc" src="./images/documentation.png" height="20"> https://kokkos.org/kokkos-core-wiki/ProgrammingGuide/Subviews.html

#### Create

```cpp
Kokkos::View<double*> view("view3D", numberOfElement);
Kokkos::View<double*> subviewAll = Kokkos::subview(view, Kokkos::ALL)
Kokkos::View<double*> subviewRange = Kokkos::subview(view, Kokkos::pair(rangeFirst, rangeLast));
Kokkos::View<double*> subviewSpecific = Kokkos::subview(view, value);
```

| Subset selection | Description                         |
|------------------|-------------------------------------|
| `Kokkos::ALL`    | All elements in this dimension      |
| `Kokkos::pair`   | Range of elements in this dimension |
| `value`          | Specific element in this dimension  |

#### Create from view

Another way of getting a subview is through the appropriate `View` constructor.

```cpp
Kokkos::View<double*> subviewAll(view, Kokkos::ALL)
Kokkos::View<double*> subviewRange(view, Kokkos::pair(rangeFirst, rangeLast));
Kokkos::View<double*> subviewSpecific(view, value);
```

### ScatterView

A `ScatterView` is a view extension that wraps an existing view in order to efficiently perform scatter operations.
Scatter operations potentially write to the same memory location from multiple threads.
`ScatterView` provides a mechanism to efficiently handle this situation by using atomics or grid duplication to update the underlying view.

<img title="Warning" alt="Warning" src="./images/warning.png" height="15"> This feature is experimental

<img title="Warning" alt="Warning" src="./images/warning.png" height="15"> Need `#include<Kokkos_ScatterView.hpp>`

<img title="Doc" alt="Doc" src="./images/documentation.png" height="20"> https://kokkos.org/kokkos-core-wiki/API/containers/ScatterView.html

<img title="Training" alt="Training" src="./images/training.png" height="20"> https://github.com/kokkos/kokkos-tutorials/blob/main/LectureSeries/KokkosTutorial_03_MDRangeMoreViews.pdf

<img title="Code" alt="Code" src="./images/code.png" height="20"> Code examples:

- [Kokkos Tutorials - ScatterView](https://github.com/kokkos/kokkos-tutorials/tree/main/Exercises/scatter_view)

#### Create

```cpp
ScatterView<DataType, Operation, ExecutionSpace, Layout, Contribution> scatter(view);
```

| Template argument | Description                                                                                                                                                   |
|-------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `DataType`        | Fundamental scalar type of the view and its dimensionality                                                                                                    |
| `Operation`       | [Operation](#scatter-operation) to perform when scattering; default to `Kokkos::Experimental::ScatterSum`                                                     |
| `ExecutionSpace`  | Memory space where the view is allocated, defaults to `Kokkos::DefaultExecutionSpace`                                                                         |
| `Layout`          | [Layout](#memory-layouts) of the view; defaults to backend and architecture most adapted layout                                                               |
| `Duplication`     | Whether to duplicate the grid or not; default to `Kokkos::Experimental::ScatterDuplicated`, other option is `Kokkos::Experimental::ScatterNonDuplicated` |
| `Contribution`    | Whether to contribute to use atomics; defaults to `Kokkos::Experimental::ScatterAtomic`, other option is `Kokkos::Experimental::ScatterNonAtomic`     |

##### Scatter operation

| Operation                           | Description                           |
|-------------------------------------|---------------------------------------|
| `Kokkos::Experimental::ScatterSum`  | Sum the contributions                 |
| `Kokkos::Experimental::ScatterProd` | Multiply the contributions            |
| `Kokkos::Experimental::ScatterMin`  | Take the minimum of the contributions |
| `Kokkos::Experimental::ScatterMax`  | Take the maximum of the contributions |

<details>
<summary>Full example</summary>

```cpp
#include<Kokkos_ScatterView.hpp>

// Compute histogram of values in view1D
KOKKOS_INLINE_FUNCTION int getIndex(double pos) { /* ... */ }
KOKKOS_INLINE_FUNCTION double compute(double weight) { /* ... */ }

// List of elements to process
Kokkos::View<double*> positions("positions", 100);
Kokkos::View<double*> weight("weight", 100);

// Historgram of N bins
Kokkos::View<double*> histogram("bar", N);

Kokkos::Experimental::ScatterView<double*> scatter(histogram);
Kokkos::parallel_for(
    100,
    KOKKOS_LAMBDA(const int i) {
        // scatter
        auto access = scatter.access();

        // compute
        auto index = getIndex(positions(i);
        auto contribution = compute(weight(i);
        access(index) += contribution;
    }
);

// gather
Kokkos::Experimental::contribute(histogram, scatter);
```

</details>

## Parallelism patterns

### For loop

```cpp
Kokkos::parallel_for(
    "label",
    ExecutionPolicy</* ... */>(/* ... */),
    KOKKOS_LAMBDA (const int i) {
        /* ... */
    }
);
```

### Reduction

```cpp
Kokkos::parallel_reduce(
    "label",
    ExecutionPolicy</* ... */>(/* ... */),
    KOKKOS_LAMBDA (const int i, double& result_in) {
        /* ... */
    },
    Kokkos::ReducerConcept<double>(result_out)
);
```

With `Kokkos::ReducerConcept` being one of the following.
The reducer class can be omitted for `Kokkos::Sum`.

| Reducer             | Operation             | Description                                |
|---------------------|-----------------------|--------------------------------------------|
| `Kokkos::BAnd`      | `&`                   | Binary and                                 |
| `Kokkos::BOr`       | `\|`                  | Binary or                                  |
| `Kokkos::LAnd`      | `&&`                  | Logical and                                |
| `Kokkos::LOr`       | `\|\|`                | Logical or                                 |
| `Kokkos::Max`       | `std::max`            | Maximum                                    |
| `Kokkos::MaxLoc`    | `std::max_element`    | Maximum and associated index               |
| `Kokkos::Min`       | `std::min`            | Minimum                                    |
| `Kokkos::MinLoc`    | `std::min_element`    | Minimum and associated index               |
| `Kokkos::MinMax`    | `std::minmax`         | Minimun and maximum                        |
| `Kokkos::MinMaxLoc` | `std::minmax_element` | Minimun and maximun and associated indices |
| `Kokkos::Prod`      | `*`                   | Product                                    |
| `Kokkos::Sum`       | `+`                   | Sum                                        |

<img title="Doc" alt="Doc" src="./images/documentation.png" height="20"> https://kokkos.org/kokkos-core-wiki/API/core/parallel-dispatch/parallel_reduce.html

<img title="Doc" alt="Doc" src="./images/documentation.png" height="20"> https://kokkos.org/kokkos-core-wiki/API/core/builtin_reducers.html

### Fences

Wait for any asynchronous operation that was running before this command to finish.

```cpp
Kokkos::fence();
```

<img title="Doc" alt="Doc" src="./images/documentation.png" height="20"> https://kokkos.org/kokkos-core-wiki/API/core/parallel-dispatch/fence.html

## Execution policy

Determines how the parallel execution should occur.

```cpp
ExecutionPolicy<ExecutionSpace, Schedule, IndexType, LaunchBounds, WorkTag> policy(/* ... */);
```

| Template argument | Description                                                                       |
|-------------------|-----------------------------------------------------------------------------------|
| `ExecutionSpace`  | Where the parallel region is executed; default to `Kokkos::DefaultExecutionSpace` |
| `Schedule`        | How to schedule work items; default to machine and backend specifics              |
| `IndexType`       | Integer type to be used for the index; default to `int64_t`                       |
| `LaunchBounds`    | Hints for CUDA and HIP launch bounds                                              |
| `WorkTag`         | Empty tag class to call the functor                                               |

<img title="Doc" alt="Doc" src="./images/documentation.png" height="20"> https://kokkos.org/kokkos-core-wiki/API/core/Execution-Policies.html

### Ranges


#### One-dimensional range

In case of work on one-dimensional arrays.

```cpp
Kokkos::RangePolicy<ExecutionSpace, Schedule, IndexType LaunchBounds, WorkTag> policy(first, last);
```

For simple ranges that start at index 0 and use default template parameters, the execution policy can be replaced by an single integer which is the number of elements.

<img title="Doc" alt="Doc" src="./images/documentation.png" height="20"> https://kokkos.org/kokkos-core-wiki/API/core/policies/RangePolicy.html

#### Multi-dimensional

In case of work on multi-dimensional arrays.
By instance for a dimension 2:

```cpp
Kokkos::MDRangePolicy<ExecutionSpace, Schedule, IndexType, LaunchBounds, WorkTag, Kokkos::Rank<2>> policy({firstI, firstJ}, {lastI, lastJ});
```

<img title="Doc" alt="Doc" src="./images/documentation.png" height="20"> https://kokkos.org/kokkos-core-wiki/API/core/policies/MDRangePolicy.html

### Hierarchical parallelism

Kokkos supports hierarchical parallelism with a *league* of *teams*, using `Kokkos::TeamPolicy`.
Parallelisation within the team depends on the specific range policy used:

| Thread level        | Vector level        | Thread and vector level | Adequate for loops of dimension |
|---------------------|---------------------|-------------------------|---------------------------------|
| `TeamThreadRange`   | `TeamVectorRange`   |                         | 2                               |
| `TeamThreadMDRange` | `TeamVectorMDRange` | `ThreadVectorRange`     | 3                               |
| *same*              | *same*              | `ThreadVectorMDRange`   | 4                               |

<img title="Doc" alt="Doc" src="./images/documentation.png" height="20"> https://kokkos.org/kokkos-core-wiki/ProgrammingGuide/HierarchicalParallelism.html

#### Team policy

```cpp
Kokkos::TeamPolicy<ExecutionSpace, Schedule, IndexType, LaunchBounds, WorkTag>(numberOfTeams, /* numberOfElementsPerTeam = */ Kokkos::AUTO);
```

**Note:** `Kokkos::AUTO` is commonly used to let Kokkos determine the number elements per team.

<img title="Doc" alt="Doc" src="./images/documentation.png" height="20"> https://kokkos.org/kokkos-core-wiki/API/core/policies/TeamPolicy.html

#### Hierarchy structure

##### Thread level or vector level

```cpp
Kokkos::parallel_for(
    "label",
    Kokkos::TeamPolicy<>(numberOfElementsI, Kokkos::AUTO),
    KOKKOS_LAMBDA (const Kokkos::TeamPolicy::member_type& teamMember) {
        const int i = teamMember.team_rank();

        Kokkos::parallel_for(
            Kokkos::TeamThreadRange(teamMember, firstJ, lastJ),
            [=] (const int j) {
                /* ... */
            }
        );
    }
);
```

##### Thread and vector level

```cpp
Kokkos::parallel_for(
    "label",
    Kokkos::TeamPolicy<>(numberOfElementsI, Kokkos::AUTO),
    KOKKOS_LAMBDA (const Kokkos::TeamPolicy::member_type& teamMember) {
        const int i = teamMember.team_rank();

        Kokkos::parallel_for(
            Kokkos::TeamThreadRange(teamMember, firstJ, lastJ),
            [=] (const int j) {
                Kokkos::parallel_for(
                    Kokkos::ThreadVectorRange(teamMember, firstK, lastK),
                    [=] (const int k) {
                        /* ... */
                    }
                );
            }
        );
    }
);
```

#### Range policy

##### One-dimensional team thread range or team vector range

```cpp
Kokkos::TeamThreadRange(teamMember, firstJ, lastJ);
Kokkos::TeamVectorRange(teamMember, firstJ, lastJ);
```

<img title="Doc" alt="Doc" src="./images/documentation.png" height="20"> https://kokkos.org/kokkos-core-wiki/API/core/policies/TeamThreadRange.html

<img title="Doc" alt="Doc" src="./images/documentation.png" height="20"> https://kokkos.org/kokkos-core-wiki/API/core/policies/TeamVectorRange.html

##### Multi-dimensional team thread range or team vector range

```cpp
Kokkos::TeamThreadMDRange<Kokkos::Rank<2>, Kokkos::TeamPolicy<>::member_type>(teamMember, numberOfElementsJ, numberOfElementsK);
Kokkos::TeamVectorMDRange<Kokkos::Rank<2>, Kokkos::TeamPolicy<>::member_type>(teamMember, numberOfElementsJ, numberOfElementsK);
```

<img title="Doc" alt="Doc" src="./images/documentation.png" height="20"> https://kokkos.org/kokkos-core-wiki/API/core/policies/TeamThreadMDRange.html

<img title="Doc" alt="Doc" src="./images/documentation.png" height="20"> https://kokkos.org/kokkos-core-wiki/API/core/policies/TeamVectorMDRange.html

##### One-dimensional team thread vector range

```cpp
Kokkos::ThreadVectorRange(teamMember, firstK, lastK);
```

<img title="Doc" alt="Doc" src="./images/documentation.png" height="20"> https://kokkos.org/kokkos-core-wiki/API/core/policies/ThreadVectorRange.html

##### Multi-dimensional team thread vector range

```cpp
Kokkos::ThreadVectorMDRange<Kokkos::Rank<2>>(teamMember, numberOfElementsK, numberOfElementsL);
```

<img title="Doc" alt="Doc" src="./images/documentation.png" height="20"> https://kokkos.org/kokkos-core-wiki/API/core/policies/ThreadVectorMDRange.html

## Scratch memory

Each Kokkos team has access to a scratch pad, only accessible by its threads.
This memory has the lifetime of the team.
This optimization is useful when all members of a team interact with the same data multiple times, and takes advantage of GPU low-latency scratch memories and CPU caches.

<img title="Doc" alt="Doc" src="./images/documentation.png" height="20"> https://kokkos.org/kokkos-core-wiki/ProgrammingGuide/HierarchicalParallelism.html#team-scratch-pad-memory

### Scratch memory space

| Space level | Memory size                 | Access speed |
|-------------|-----------------------------|--------------|
| 0           | Limited (tens of kilobytes) | Fast         |
| 1           | Larger (few gigabytes)      | Medium       |

### Create and populate

```cpp
// Define a scratch memory view type
using ScratchPadView = View<double*, ExecutionSpace::scratch_memory_space, MemoryUnmanaged>;

// Compute how much scratch memory (in bytes) is needed
size_t bytes = ScratchPadView::shmem_size(vectorSize);

Kokkos::parallel_for(
    Kokkos::TeamPolicy<ExecutionSpace>(numberOfTeams, numberOfElementsPerTeam).set_scratch_size(spaceLevel, Kokkos::PerTeam(bytes)),
    KOKKOS_LAMBDA (const member_type &teamMember) {
        const int i = teamMember.team_rank();

        // Create a view for the scratch pad
        ScratchPadView scratch(teamMember.team_scratch(spaceLevel), vectorSize);

        Kokkoss::parallel_for(
            Kokkos::ThreadVectorRange(teamMember, vectorSize),
            [=] (const int j) {
                scratch(j) = view(i, j);
            }
        );

        teamMember.team_barrier();

        /* ... */
    }
);
```

## Atomics

Atomics are used when multiple threads simultaneously update the same data element.

<img title="Doc" alt="Doc" src="./images/documentation.png" height="20"> https://kokkos.org/kokkos-core-wiki/ProgrammingGuide/Atomic-Operations.html

<img title="Doc" alt="Doc" src="./images/documentation.png" height="20"> https://kokkos.org/kokkos-core-wiki/API/core/atomics.html

### Atomic operations

| Operation                  | Replaces                             |
|----------------------------|--------------------------------------|
| `Kokkos::atomic_add`       | `+=`                                 |
| `Kokkos::atomic_and`       | `&=`                                 |
| `Kokkos::atomic_assign`    | `=`                                  |
| `Kokkos::atomic_decrement` | `--`                                 |
| `Kokkos::atomic_increment` | `++`                                 |
| `Kokkos::atomic_max`       | `std::max` on previous and new value |
| `Kokkos::atomic_min`       | `std::min` on previous and new value |
| `Kokkos::atomic_or`        | `\|=`                                |
| `Kokkos::atomic_sub`       | `-=`                                 |

<details>
<summary>Example</summary>

```cpp
Kokkos::parallel_for(
    numberOfElements,
    KOKKOS_LAMBDA (const int i) {
        const int value = /* ... */;
        const int bucketIndex = computeBucketIndex (value);
        Kokkos::atomic_increment(&histogram(bucketIndex));
    }
);
```

</details>

### Atomic exchanges

| Operation                                | Description                                                            |
|------------------------------------------|------------------------------------------------------------------------|
| `Kokkos::atomic_exchange`                | Assign destination to new value and return old value                   |
| `Kokkos::atomic_compare_exchange_strong` | Assign destination to new value if old value equals a comparison value |

<details>
<summary>Example</summary>

```cpp
// Assign destination to new value and return old value
int new = 20;
int destination = 10;
int old = atomic_exchange(&destination, new);

// Assign destination to new value if old value equals a comparison value
int new = 20;
int destination = 10;
int comparison = 10;
bool success = atomic_compare_exchange_strong(&destination, comparison, new);
```

</details>

## Macros
