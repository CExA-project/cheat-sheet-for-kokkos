<!--#ifndef PRINT-->

# Kokkos utilization cheat sheet

<img title="Warning" alt="Warning" src="./images/warning_txt.svg" height="25"> Only for Kokkos 4.2 and more, for older verison look at the doc.

- [Kokkos utilization cheat sheet](#kokkos-utilization-cheat-sheet)
  - [Initialization](#initialization)
    - [Headers](#headers)
    - [Initialize and finalize Kokkos](#initialize-and-finalize-kokkos)
      - [Command-line arguments](#command-line-arguments)
      - [Struct arguments](#struct-arguments)
  - [Memory management](#memory-management)
    - [View](#view)
      - [Creating a view](#creating-a-view)
      - [Accessing elements](#accessing-elements)
      - [Managing views](#managing-views)
    - [Memory Layout](#memory-layout)
    - [Memory space](#memory-space)
      - [Generic memory space](#generic-memory-space)
      - [Unified virtual memory or shared space](#unified-virtual-memory-or-shared-space)
      - [Scratch memory space](#scratch-memory-space)
    - [Memory trait](#memory-trait)
    - [View copy](#view-copy)
    - [Mirror view](#mirror-view)
      - [Create and allocate](#create-and-allocate)
      - [Create and conditionally allocate](#create-and-conditionally-allocate)
      - [Synchronize](#synchronize)
    - [Subview](#subview)
      - [Create](#create)
      - [Create from view](#create-from-view)
    - [ScatterView](#scatterview)
      - [Create](#create-1)
        - [Scatter operation](#scatter-operation)
  - [Parallelism patterns](#parallelism-patterns)
    - [For loop](#for-loop)
    - [Reduction](#reduction)
    - [Fences](#fences)
  - [Execution policy](#execution-policy)
    - [Execution space](#execution-space)
    - [Ranges](#ranges)
      - [One-dimensional range](#one-dimensional-range)
      - [Multi-dimensional](#multi-dimensional)
    - [Hierarchical parallelism](#hierarchical-parallelism)
      - [Team policy](#team-policy)
      - [Hierarchy structure](#hierarchy-structure)
        - [Thread level or vector level](#thread-level-or-vector-level)
        - [Thread and vector level](#thread-and-vector-level)
      - [Range policy](#range-policy)
        - [One-dimensional team thread range or team vector range](#one-dimensional-team-thread-range-or-team-vector-range)
        - [Multi-dimensional team thread range or team vector range](#multi-dimensional-team-thread-range-or-team-vector-range)
        - [One-dimensional team thread vector range](#one-dimensional-team-thread-vector-range)
        - [Multi-dimensional team thread vector range](#multi-dimensional-team-thread-vector-range)
  - [Scratch memory](#scratch-memory)
    - [Scratch memory space](#scratch-memory-space-1)
    - [Create and populate](#create-and-populate)
  - [Atomics](#atomics)
    - [Atomic operations](#atomic-operations)
    - [Atomic exchanges](#atomic-exchanges)
  - [Mathematics](#mathematics)
    - [Math functions](#math-functions)
    - [Complex numbers](#complex-numbers)
  - [Utilities](#utilities)
    - [Code interruption](#code-interruption)
    - [Print inside a kernel](#print-inside-a-kernel)
    - [Timer](#timer)
    - [Manage parallel environment](#manage-parallel-environment)
  - [Macros](#macros)
    - [Essential macros](#essential-macros)
    - [Extra macros](#extra-macros)

<!--#endif-->

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

<!--#ifndef PRINT-->
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://kokkos.org/kokkos-core-wiki/API/core/view/view.html
<!--#endif-->

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

<!--#ifndef PRINT-->
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://kokkos.org/kokkos-core-wiki/API/core/view/view.html#constructors

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
<!--#endif-->

#### Accessing elements

```cpp
for (int i = 0; i < 10; i++) {
    for (int j = 0; j < 50; ++j) {
        view(i, j) = i + j;
    }
}
```

<!--#ifndef PRINT-->
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://kokkos.org/kokkos-core-wiki/API/core/view/view.html#data-access-functions
<!--#endif-->

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

<!--#ifndef PRINT-->
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://kokkos.org/kokkos-core-wiki/API/core/view/view.html#data-layout-dimensions-strides
<!--#endif-->

### Memory Layout

Layout Determines the mapping of indices into the underlying 1D memory storage:

| Layout                   | Description                                                     | Other name                   | Efficient for |
|--------------------------|-----------------------------------------------------------------|------------------------------|---------------|
| `Kokkos::LayoutRight()`  | Strides increase from the right most to the left most dimension | row-major or C-like          | CPU           |
| `Kokkos::LayoutLeft()`   | Strides increase from the left most to the right most dimension | column-major or Fortran-like | GPU           |
| `Kokkos::LayoutStride()` | Strides can arbitrary for each dimension                        |                              |               |

If no layouts are specified, the most efficient one for the memory space is used.
For performance, memory access patterns must result in caching on a CPU and coalescing on a GPU.

<!--#ifndef PRINT-->
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://kokkos.org/kokkos-core-wiki/API/core/view/view.html#data-layout-dimensions-strides

<details>
<summary>Example</summary>

```cpp
// 2D view with LayoutRight
Kokkos::View<double**, Kokkos::LayoutRight> view2D("view2D", 50, 50);
```

</details>
<!--#endif-->

### Memory space

Abstraction to represent the “where” and the “how” the memory allocation and access takes place in Kokkos.
Most code should be written to the generic concept of a memory space rather than any specific instance.

<!--#ifndef PRINT-->
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://kokkos.org/kokkos-core-wiki/API/core/memory_spaces.html
<!--#endif-->

#### Generic memory space

| Memory space                                      | Description                                                                                                                                          |
|---------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `Kokkos::DefaultExecutionSpace::memory_space`     | Default memory space of the default execution space, used by default                                                                                 |
| `Kokkos::DefaultHostExecutionSpace::memory_space` | Default memory space of the default host execution space; same as `Kokkos::DefaultExecutionSpace::memory_space` if the code is compiled for CPU only |
| `Kokkos::HostSpace`                               | Default memory space for data that resides on the host, accessible from the host but not directly from the GPU                                       |

<!--#ifndef PRINT-->
<details>
<summary>Example</summary>

```cpp
Kokkos::View<double*, Kokkos::HostSpace> hostView("hostView", numberOfElements);
```

</details>
<!--#endif-->

#### Unified virtual memory or shared space

| Memory space          | Description                                                                                                                                                                                                  |
|-----------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `Kokkos::SharedSpace` | Data that can be accessed by any enabled execution space using the UVM concept; the movement is done automatically by the driver at the moment of access, performance depends on hardware and driver support |

<!--#ifndef PRINT-->
<details>
<summary>Example</summary>

```cpp
Kokkos::View<double*, Kokkos::SharedSpace> sharedView("sharedView", numberOfElements);
```

</details>
<!--#endif-->

#### Scratch memory space

| Memory space                 | Description                                                                                                               |
|------------------------------|---------------------------------------------------------------------------------------------------------------------------|
| `Kokkos::ScratchMemorySpace` | Temporary data within parallel constructs which is allocated per thread or per team of threads and is not visible outside |

<!--#ifndef PRINT-->
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
<!--#endif-->

### Memory trait

| Memory trait           | Description                                                                                                                                                       |
|------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `Kokkos::Unmanaged`    | The view will not be reference counted; the allocation has to be provided to the constructor                                                                      |
| `Kokkos::Atomic`       | All accesses to the view will use atomic operations                                                                                                               |
| `Kokkos::RandomAccess` | Hint that the view is used in a random access manner; if the view is also `const` this will trigger special load operations on GPUs (e.g. texture memory on CUDA) |
| `Kokkos::Restrict`     | There is no aliasing of the view by other data structures in the current scope                                                                                    |

Memory traits can be combined using the `Kokkos::MemoryTraits<>` class and `|`.

<!--#ifndef PRINT-->
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://kokkos.org/kokkos-core-wiki/ProgrammingGuide/View.html#access-traits

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
<!--#endif-->

### View copy

<img title="Warning" alt="Warning" src="./images/warning_txt.svg" height="25"> Copying or assigning a view does a shallow copy, and just changes the reference count.
Data are not synchronized in this case.

```cpp
Kokkos::deep_copy(dest, src);
```

Copies data from `src` view to `dest` view.
The views must have the same dimensions, data type and reside in the same memory space ([mirror views](#mirror-view) can be deep copied on different memory spaces).

<!--#ifndef PRINT-->
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://kokkos.org/kokkos-core-wiki/API/core/view/deep_copy.html

<img title="Code" alt="Code" src="./images/code_txt.svg" height="25">

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
<!--#endif-->

### Mirror view

A `HostMirror` view is allocated in the host memory space as a mirror of a device view.

<!--#ifndef PRINT-->
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://kokkos.org/kokkos-core-wiki/API/core/view/create_mirror.html

<img title="Code" alt="Code" src="./images/code_txt.svg" height="25">

- [Kokkos example - simple memoryspace](https://github.com/kokkos/kokkos/blob/master/example/tutorial/04_simple_memoryspaces/simple_memoryspaces.cpp)
- [Kokkos Tutorials - Exercise 3](https://github.com/kokkos/kokkos-tutorials/blob/main/Exercises/03/Solution/exercise_3_solution.cpp)
<!--#endif-->

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

<img title="Warning" alt="Warning" src="./images/warning_txt.svg" height="25"> A subview has the same reference count as its parent View, so the parent View won’t be deallocated before all subviews go away.

<img title="Warning" alt="Warning" src="./images/warning_txt.svg" height="25"> Every subview is also a view. This means that you may take a subview of a subview.

<!--#ifndef PRINT-->
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://kokkos.org/kokkos-core-wiki/API/core/view/subview.html

<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://kokkos.org/kokkos-core-wiki/ProgrammingGuide/Subviews.html
<!--#endif-->

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

<img title="Warning" alt="Warning" src="./images/warning_txt.svg" height="25"> This feature is experimental

<img title="Warning" alt="Warning" src="./images/warning_txt.svg" height="25"> Need `#include<Kokkos_ScatterView.hpp>`

<!--#ifndef PRINT-->
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://kokkos.org/kokkos-core-wiki/API/containers/ScatterView.html

<img title="Training" alt="Training" src="./images/tutorial_txt.svg" height="25"> https://github.com/kokkos/kokkos-tutorials/blob/main/LectureSeries/KokkosTutorial_03_MDRangeMoreViews.pdf

<img title="Code" alt="Code" src="./images/code_txt.svg" height="25"> 

- [Kokkos Tutorials - ScatterView](https://github.com/kokkos/kokkos-tutorials/tree/main/Exercises/scatter_view)
<!--#endif-->

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

<!--#ifndef PRINT-->
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
<!--#endif-->

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

<!--#ifndef PRINT-->
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://kokkos.org/kokkos-core-wiki/API/core/parallel-dispatch/parallel_reduce.html

<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://kokkos.org/kokkos-core-wiki/API/core/builtin_reducers.html
<!--#endif-->

### Fences

Wait for any asynchronous operation that was running before this command to finish.

```cpp
Kokkos::fence();
```

<!--#ifndef PRINT-->
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25">  https://kokkos.org/kokkos-core-wiki/API/core/parallel-dispatch/fence.html
<!--#endif-->

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

<!--#ifndef PRINT-->
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://kokkos.org/kokkos-core-wiki/API/core/Execution-Policies.html
<!--#endif-->

### Execution space

<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://kokkos.org/kokkos-core-wiki/API/core/execution_spaces.html

Execution spaces are where and how the parallel region is executed (Host or Device and the choice of the corresponding programming model).

| Spaces | Description                                                                       |
|-------------------|-----------------------------------------------------------------------------------|
| `Kokkos::DefaultExecutionSpace`  | Default execution space, if Kokkos is compiled with both a Host and a Device backend, it will be the device space |
| `Kokkos::DefaultHostExecutionSpace`  | Default host execution space, if Kokkos is compiled with both a Host and a Device backend, it will be the host space |
| `Kokkos::Serial`  | Serial execution space, for debugging and testing purposes |

### Ranges

#### One-dimensional range

In case of work on one-dimensional arrays.

```cpp
Kokkos::RangePolicy<ExecutionSpace, Schedule, IndexType LaunchBounds, WorkTag> policy(first, last);
```

For simple ranges that start at index 0 and use default template parameters, the execution policy can be replaced by an single integer which is the number of elements.

<!--#ifndef PRINT-->
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://kokkos.org/kokkos-core-wiki/API/core/policies/RangePolicy.html
<!--#endif-->

#### Multi-dimensional

In case of work on multi-dimensional arrays.
By instance for a dimension 2:

```cpp
Kokkos::MDRangePolicy<ExecutionSpace, Schedule, IndexType, LaunchBounds, WorkTag, Kokkos::Rank<2>> policy({firstI, firstJ}, {lastI, lastJ});
```

<!--#ifndef PRINT-->
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://kokkos.org/kokkos-core-wiki/API/core/policies/MDRangePolicy.html
<!--#endif-->

### Hierarchical parallelism

Kokkos supports hierarchical parallelism with a *league* of *teams*, using `Kokkos::TeamPolicy`.
Parallelisation within the team depends on the specific range policy used:

| Thread level        | Vector level        | Thread and vector level | Adequate for loops of dimension |
|---------------------|---------------------|-------------------------|---------------------------------|
| `TeamThreadRange`   | `TeamVectorRange`   |                         | 2                               |
| `TeamThreadMDRange` | `TeamVectorMDRange` | `ThreadVectorRange`     | 3                               |
| *same*              | *same*              | `ThreadVectorMDRange`   | 4                               |

<!--#ifndef PRINT-->
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://kokkos.org/kokkos-core-wiki/ProgrammingGuide/HierarchicalParallelism.html
<!--#endif-->

#### Team policy

```cpp
Kokkos::TeamPolicy<ExecutionSpace, Schedule, IndexType, LaunchBounds, WorkTag>(numberOfTeams, /* numberOfElementsPerTeam = */ Kokkos::AUTO);
```

`Kokkos::AUTO` is commonly used to let Kokkos determine the number elements per team.

<!--#ifndef PRINT-->
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://kokkos.org/kokkos-core-wiki/API/core/policies/TeamPolicy.html
<!--#endif-->

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

<!--#ifndef PRINT-->
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://kokkos.org/kokkos-core-wiki/API/core/policies/TeamThreadRange.html

<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://kokkos.org/kokkos-core-wiki/API/core/policies/TeamVectorRange.html
<!--#endif-->

##### Multi-dimensional team thread range or team vector range

```cpp
Kokkos::TeamThreadMDRange<Kokkos::Rank<2>, Kokkos::TeamPolicy<>::member_type>(teamMember, numberOfElementsJ, numberOfElementsK);
Kokkos::TeamVectorMDRange<Kokkos::Rank<2>, Kokkos::TeamPolicy<>::member_type>(teamMember, numberOfElementsJ, numberOfElementsK);
```

<!--#ifndef PRINT-->
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://kokkos.org/kokkos-core-wiki/API/core/policies/TeamThreadMDRange.html

<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://kokkos.org/kokkos-core-wiki/API/core/policies/TeamVectorMDRange.html
<!--#endif-->

##### One-dimensional team thread vector range

```cpp
Kokkos::ThreadVectorRange(teamMember, firstK, lastK);
```

<!--#ifndef PRINT-->
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://kokkos.org/kokkos-core-wiki/API/core/policies/ThreadVectorRange.html
<!--#endif-->

##### Multi-dimensional team thread vector range

```cpp
Kokkos::ThreadVectorMDRange<Kokkos::Rank<2>>(teamMember, numberOfElementsK, numberOfElementsL);
```

<!--#ifndef PRINT-->
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25">  https://kokkos.org/kokkos-core-wiki/API/core/policies/ThreadVectorMDRange.html
<!--#endif-->

## Scratch memory

Each Kokkos team has access to a scratch pad, only accessible by its threads.
This memory has the lifetime of the team.
This optimization is useful when all members of a team interact with the same data multiple times, and takes advantage of GPU low-latency scratch memories and CPU caches.

<!--#ifndef PRINT-->
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25">  https://kokkos.org/kokkos-core-wiki/ProgrammingGuide/HierarchicalParallelism.html#team-scratch-pad-memory
<!--#endif-->

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
  
<!--#ifndef PRINT-->
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://kokkos.org/kokkos-core-wiki/ProgrammingGuide/Atomic-Operations.html

<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://kokkos.org/kokkos-core-wiki/API/core/atomics.html
<!--#endif-->

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

<!--#ifndef PRINT-->
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
<!--#endif-->

### Atomic exchanges

| Operation                                | Description                                                            |
|------------------------------------------|------------------------------------------------------------------------|
| `Kokkos::atomic_exchange`                | Assign destination to new value and return old value                   |
| `Kokkos::atomic_compare_exchange_strong` | Assign destination to new value if old value equals a comparison value |

<!--#ifndef PRINT-->
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
<!--#endif-->

## Mathematics

### Math functions

Consistent overload set that is available on host and device that follows practice from the C++ numerics library.

<img title="Warning" alt="Warning" src="./images/warning_txt.svg" height="25"> Should be used on device prefixed by `Kokkos::`

| Function type | List of available functions                                                                    |
|-------------------|-----------------------------------------------------------------------------------|
| Basic operations  | `abs`, `fabs`, `fmod`, `remainder`, `fma`, `fmax`, `fmin`, `fdim`, `nan` |
| Exponential       | `exp`, `exp2`, `expm1`, `log`, `log2`, `log10`, `log1p` |
| Power             | `pow`, `sqrt`, `cbrt`, `hypot` |
| Trigonometric     | `sin`, `cos`, `tan`, `asin`, `acos`, `atan`, `atan2` |
| Hyperbolic        | `sinh`, `cosh`, `tanh`, `asinh`, `acosh`, `atanh` |
| Error and gamma   | `erf`, `erfc`, `tgamma`, `lgamma` |
| Nearest    | `ceil`, `floor`, `trunc`, `round`, `nearbyint` |
| Floating point manipulation | `logb`, `nextafter`, `copysign` |
| Classification and comparison | `isfinite`, `isinf`, `isnan`, `signbit` |

<img title="Warning" alt="Warning" src="./images/warning_txt.svg" height="25"> The `Kokkos` namespace is not a complete replacement for the C++ numerics library, and some functions are not available.

<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://kokkos.org/kokkos-core-wiki/API/core/numerics/mathematical-functions.html?highlight=math

### Complex numbers

`Kokkos::complex` is a portable complex number implementation.

| Methods  | Description|
|------------------------------------------|------------------------------------------------------------------------|
| `Kokkos::complex<double> complexValue(realPart, imagPart)` | Constructor |
| `real()`                                 | Returns or set the real part of the complex number                            |
| `imag()`                                 | Returns or set the imaginary part of the complex number     |

<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://kokkos.org/kokkos-core-wiki/API/core/utilities/complex.html?highlight=complex

## Utilities

<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://kokkos.org/kokkos-core-wiki/API/core/Utilities.html

### Code interruption

- `Kokkos::abort(const char *const msg)`: function that can be used to terminate the execution of a Kokkos program.

### Print inside a kernel

- `Kokkos::printf(const char* format, Args... args);`: Prints the data specified in format and args... to stdout. The behavior is analogous to `std::printf`, but the return type is void to ensure a consistent behavior across backends.

### Timer

- `kokkos::timer`: A simple timer class that can be used to measure the time taken by a block of code.

| Methods                                | Description                                                            |
|------------------------------------------|------------------------------------------------------------------------|
| `timer::timer()`                         | Constructor                                                            |
| `timer::seconds()`                       | Returns the time in seconds since the timer was constructed or the last reset                |
| `timer::reset()`                         | Resets the timer to zero                                               |

### Manage parallel environment

| Functions                                | Description                                                            |
|------------------------------------------|------------------------------------------------------------------------|
| `Kokkos::device_id()`                    | Returns the device id of the current device                            |
| `Kokkos::num_devices()`                  | Returns the number of devices available to the current execution space |
| `Kokkos::num_threads`                    | Returns the number of threads in the current team                      |

## Macros

<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://kokkos.org/kokkos-core-wiki/API/core/Macros.html

### Essential macros

| Macros                                | Description                                                            |
|------------------------------------------|------------------------------------------------------------------------|
| `KOKKOS_LAMBDA`                          | To build a Kokkos lambda                                               |
| `KOKKOS_FUNCTION`                        | Specify that a method can be used in a Kokkos parallel construct        |
| `KOKKOS_INLINE_FUNCTION`                 | Specify that a method can be used in a Kokkos parallel construct with the inline attribute |

### Extra macros

| Macros                                | Description                                                            |
|------------------------------------------|------------------------------------------------------------------------|
| `KOKKOS_VERSION`                         | The Kokkos version; `KOKKOS_VERSION % 100` is the patch level, `KOKKOS_VERSION / 100 % 100` is the minor version, and `KOKKOS_VERSION / 10000` is the major version. |
| `KOKKOS_ENABLE_*`                        | with `*` being one of the available general setting, execution space, backend option, C++ version or third-party libraries. It defines if the specified option is enabled. [See complete list online](https://kokkos.org/kokkos-core-wiki/API/core/Macros.html) |
| `KOKKOS_ARCH_*` | with `*` being one of the available architecture options defines if the specified architecture option is enabled. [See complete list online](https://kokkos.org/kokkos-core-wiki/API/core/Macros.html) |
