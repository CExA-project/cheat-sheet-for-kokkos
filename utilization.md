<!--#ifndef PRINT-->

# Kokkos utilization cheat sheet

<img title="Warning" alt="Warning" src="./images/warning_txt.svg" height="25"> Only for Kokkos 4.2 and more, for older verison look at the doc.

1. [Header](#header)
2. [Initialization](#initialization)
	1. [Initialize and finalize](#initialize-and-finalize)
	2. [Scope guard](#scope-guard)
3. [Kokkos concepts](#kokkos-concepts)
	1. [Execution spaces](#execution-spaces)
	2. [Memory spaces](#memory-spaces)
		1. [Generic memory spaces](#generic-memory-spaces)
		2. [Specific memory spaces](#specific-memory-spaces)
3. [Memory management](#memory-management)
	1. [View](#view)
		1. [Creating a view](#creating-a-view)
		2. [Accessing elements](#accessing-elements)
		3. [Managing views](#managing-views)
	2. [Memory Layouts](#memory-layouts)
	3. [Memory trait](#memory-trait)
	4. [Deep copy](#deep-copy)
	5. [Mirror view](#mirror-view)
		1. [Create and allocate](#create-and-allocate)
		2. [Create and conditionally allocate](#create-and-conditionally-allocate)
		3. [Create, conditionally allocate and conditionnaly synchronize](#create-conditionally-allocate-and-conditionnaly-synchronize)
		4. [Synchronize](#synchronize)
	6. [Subview](#subview)
		1. [Create](#create)
	7. [ScatterView](#scatterview)
		1. [Specific header](#specific-header)
		2. [Create](#create)
			1. [Scatter operation](#scatter-operation)
3. [Parallelism patterns](#parallelism-patterns)
	1. [For loop](#for-loop)
	2. [Reduction](#reduction)
	3. [Fences](#fences)
		1. [Global fence](#global-fence)
		2. [Execution space fence](#execution-space-fence)
4. [Execution policy](#execution-policy)
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
6. [Mathematics](#mathematics)
	1. [Math functions](#math-functions)
	2. [Complex numbers](#complex-numbers)
		1. [Create](#create)
		2. [Manage](#manage)
3. [Utilities](#utilities)
	1. [Code interruption](#code-interruption)
	2. [Print inside a kernel](#print-inside-a-kernel)
	3. [Timer](#timer)
		1. [Create](#create)
		2. [Manage](#manage)
	4. [Manage parallel environment](#manage-parallel-environment)
4. [Macros](#macros)
	1. [Essential macros](#essential-macros)
	2. [Extra macros](#extra-macros)

<!--#endif-->

## Header

```cpp
#include <Kokkos_Core.hpp>
```

## Initialization

### Initialize and finalize

```cpp
int main(int argc, char* argv[]) {
    Kokkos::initialize();
    {
        /* ... */
    }
    Kokkos::finalize();
    return 0;
}
```

### Scope guard

```cpp
int main(int argc, char* argv[]) {
    Kokkos::ScopeGuard kokkos();
    /* ... */
    return 0;
}
```

## Kokkos concepts

### Execution spaces

Where and how a parallel region is executed.

| Execution space                     | Device backend | Host backend |
|-------------------------------------|----------------|--------------|
| `Kokkos::DefaultExecutionSpace`     | On device      | On host      |
| `Kokkos::DefaultHostExecutionSpace` | On host        | On host      |
| `Kokkos::Serial`                    | On host        | On host      |

`Kokkos::Serial` is used for debug purpose only.

<!--#ifndef PRINT-->
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://kokkos.org/kokkos-core-wiki/API/core/execution_spaces.html
<!--#endif-->

### Memory spaces

Where and how data is stored.

<!--#ifndef PRINT-->
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://kokkos.org/kokkos-core-wiki/API/core/memory_spaces.html
<!--#endif-->

#### Generic memory spaces

| Memory space                                      | Device backend | Host backend |
|---------------------------------------------------|----------------|--------------|
| `Kokkos::DefaultExecutionSpace::memory_space`     | On device      | On host      |
| `Kokkos::DefaultHostExecutionSpace::memory_space` | On host        | On host      |

#### Specific memory spaces

| Memory space                 | Description                                                                                                                                                         |
|------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `Kokkos::HostSpace`          | Accessible from the host but not directly from the device                                                                                                           |
| `Kokkos::SharedSpace`        | Accessible by the host and the device; the movement is done automatically by the driver at the moment of access, performance depends on hardware and driver support |
| `Kokkos::ScratchMemorySpace` | Accessible by the team or thread that created it and nothing else; used for temporary data within parallel constructs                                               |

<!--#ifndef PRINT-->
<details>
<summary>Examples</summary>

```cpp
// Host space
Kokkos::View<double*, Kokkos::HostSpace> hostView("hostView", numberOfElements);

// Shared space
Kokkos::View<double*, Kokkos::SharedSpace> sharedView("sharedView", numberOfElements);

// Scratch memory space
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
|-------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `DataType`        | Fundamental scalar type of the view and its dimensionality; syntax is `ScalarType*[]` where the number of `*` denotes the number of runtime length dimensions (dynamic allocation) and the number of `[]` defines the compile time dimensions (static allocation); runtime dimensions must come first |
| `LayoutType`      | See [memory layouts](#memory-layouts)                                                                                                                                                                                                                                                                        |
| `MemorySpace`     | See [memory spaces](#memory-spaces)                                                                                                                                                                                                                                                                          |
| `MemoryTraits`    | See [memory traits](#memory-traits)                                                                                                                                                                                                                                                                          |

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

#### Managing views

| Method      | Description                                                                                                           |
|-------------|-----------------------------------------------------------------------------------------------------------------------|
| `(i, j...)` | Returns and sets the value                                                                                            |
| `size()`    | Returns the total number of elements in the view                                                                      |
| `rank()`    | Returns the number of dimensions                                                                                      |
| `extent()`  | Returns the number of elements in each dimension                                                                      |
| `layout()`  | Returns the layout of the view                                                                                        |
| `resize()`  | Reallocates a view to have the new dimensions; can grow or shrink, and will preserve content of the common subextents |
| `realloc()` | Reallocates a view to have the new dimensions; can grow or shrink, and will not preserve content                      |
| `data()`    | Returns a pointer to the underlying data                                                                              |

<!--#ifndef PRINT-->
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://kokkos.org/kokkos-core-wiki/API/core/view/view.html#data-access-functions

<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://kokkos.org/kokkos-core-wiki/API/core/view/view.html#data-layout-dimensions-strides
<!--#endif-->

### Memory Layouts

Determines the mapping of indices into the underlying 1D memory storage.

| Layout                 | Description                                                                                                 | For |
|------------------------|-------------------------------------------------------------------------------------------------------------|-----|
| `Kokkos::LayoutRight`  | Strides increase from the right most to the left most dimension, also known as row-major or C-like          | CPU |
| `Kokkos::LayoutLeft`   | Strides increase from the left most to the right most dimension, also known as column-major or Fortran-like | GPU |
| `Kokkos::LayoutStride` | Strides can be arbitrary for each dimension                                                                 |     |

If no layouts are specified, the most efficient one for the memory space is used.
Memory caching on CPU and coalescing on GPU gives the best performance.

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

### Memory trait

Memory traits are indicated with `Kokkos::MemoryTraits<>`.

| Memory trait           | Description                                                                                                                                                       |
|------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `Kokkos::Unmanaged`    | The view will not be reference counted; the allocation has to be provided to the constructor                                                                      |
| `Kokkos::Atomic`       | All accesses to the view will use atomic operations                                                                                                               |
| `Kokkos::RandomAccess` | Hint that the view is used in a random access manner; if the view is also `const` this will trigger special load operations on GPUs (e.g. texture memory on CUDA) |
| `Kokkos::Restrict`     | There is no aliasing of the view by other data structures in the current scope                                                                                    |

Several memory traits are combined with the `|` (pipe) operator.

<!--#ifndef PRINT-->
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://kokkos.org/kokkos-core-wiki/ProgrammingGuide/View.html#access-traits

<details>
<summary>Examples</summary>

```cpp
// Unmanaged view on CPU
double* data = new double[numberOfElements];
Kokkos::View<double*, Kokkos::MemoryTraits<Kokkos::Unmanaged>> unmanagedView(data, numberOfElements);

// Unmanaged view on GPU using CUDA
double* data;
cudaMalloc(&data, numberOfElements * sizeof(double));
Kokkos::View<double*, Kokkos::MemoryTraits<Kokkos::Unmanaged>, Kokkos::CudaSpace> unmanagedView(data, numberOfElements);

// Atomic view
Kokkos::View<double*, Kokkos::MemoryTraits<Kokkos::Atomic>> atomicView("atomicView", numberOfElements);

// Random access with constant data
// first, allocate non constant view
Kokkos::View<int*> nonConstView ("data", numberOfElements);
// then, make it constant
Kokkos::View<const int*, Kokkos::MemoryTraits<Kokkos::RandomAccess>> randomAccessView = nonConstView;

// Unmanaged, atomic, random access view on GPU using CUDA
double* data;
cudaMalloc(&data, numberOfElements* sizeof(double));
Kokkos::View<const double*,  Kokkos::CudaSpace, Kokkos::MemoryTraits<Kokkos::Unmanaged | Kokkos::Atomic | Kokkos::RandomAccess>> unmanagedView(data, numberOfElements);
```

</details>
<!--#endif-->

### Deep copy

<img title="Warning" alt="Warning" src="./images/warning_txt.svg" height="25"> Copying or assigning a view does a shallow copy, and just changes the reference count: data are not synchronized in this case.

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

// Deep copy of view1 to view2
Kokkos::deep_copy(view2, view1);
```

</details>
<!--#endif-->

### Mirror view

A view, usually in the host memory space, which mirrors another view, either in the device or the host memory space.

<!--#ifndef PRINT-->
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://kokkos.org/kokkos-core-wiki/API/core/view/create_mirror.html

<img title="Code" alt="Code" src="./images/code_txt.svg" height="25">

- [Kokkos example - simple memoryspace](https://github.com/kokkos/kokkos/blob/master/example/tutorial/04_simple_memoryspaces/simple_memoryspaces.cpp)
- [Kokkos Tutorials - Exercise 3](https://github.com/kokkos/kokkos-tutorials/blob/main/Exercises/03/Solution/exercise_3_solution.cpp)
<!--#endif-->

#### Create and allocate

```cpp
auto hostView = Kokkos::create_mirror(view);
```

Create a host mirror view of a device view and always allocate data.

#### Create and conditionally allocate

```cpp
auto hostView = Kokkos::create_mirror_view(view);
```

Create a host mirror view of a device view, but only allocate data if the source view is not in the host space.

#### Create, conditionally allocate and conditionnaly synchronize
```cpp
auto hostView = Kokkos::create_mirror_view_and_copy(ExecutionSpace(), view);
```

Create a mirror view on `ExecutionSpace::memory_space` of a view, but only allocate and synchronize data if the source view is not in the same space.

#### Synchronize

See [deep copy](#deep-copy).

### Subview

A view that is a subset of another view, similarly to languages such as Python or Fortran.
It is possible to has a subview of a subview.

<img title="Warning" alt="Warning" src="./images/warning_txt.svg" height="25"> A subview has the same reference count as its parent view, so the parent view won’t be deallocated before all subviews go away.

<!--#ifndef PRINT-->
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://kokkos.org/kokkos-core-wiki/API/core/view/subview.html

<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://kokkos.org/kokkos-core-wiki/ProgrammingGuide/Subviews.html
<!--#endif-->

#### Create

```cpp
auto subview = Kokkos::subview(view, Kokkos::ALL, Kokkos::pair(rangeFirst, rangeLast), value);
```

| Subset selection | Description                         |
|------------------|-------------------------------------|
| `Kokkos::ALL`    | All elements in this dimension      |
| `Kokkos::pair`   | Range of elements in this dimension |
| `value`          | Specific element in this dimension  |

### Scatter view

View extension that wraps an existing view in order to perform scatter operations.
As this may result to race conditions, `ScatterView` uses atomics or grid duplication.

<img title="Warning" alt="Warning" src="./images/warning_txt.svg" height="25"> This feature is experimental


<!--#ifndef PRINT-->
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://kokkos.org/kokkos-core-wiki/API/containers/ScatterView.html

<img title="Training" alt="Training" src="./images/tutorial_txt.svg" height="25"> https://github.com/kokkos/kokkos-tutorials/blob/main/LectureSeries/KokkosTutorial_03_MDRangeMoreViews.pdf

<img title="Code" alt="Code" src="./images/code_txt.svg" height="25"> 

- [Kokkos Tutorials - ScatterView](https://github.com/kokkos/kokkos-tutorials/tree/main/Exercises/scatter_view)
<!--#endif-->

#### Specific header

```cpp
#include <Kokkos_ScatterView.hpp>
```

#### Create

```cpp
ScatterView<DataType, Operation, ExecutionSpace, Layout, Contribution> scatter(targetView);
```

| Template argument | Description                                                                                                                                                |
|-------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `DataType`        | Scalar type of the view and its dimensionality                                                                                                             |
| `Operation`       | See [scatter operation](#scatter-operation); defaults to `Kokkos::Experimental::ScatterSum`                                                                |
| `ExecutionSpace`  | See [execution spaces](#executiondspaces); defaults to `Kokkos::DefaultExecutionSpace`                                                                     |
| `Layout`          | See [layouts](#memory-layouts)                                                                                                                             |
| `Duplication`     | Whether to duplicate the grid or not; defaults to `Kokkos::Experimental::ScatterDuplicated`, other option is `Kokkos::Experimental::ScatterNonDuplicated` |
| `Contribution`    | Whether to contribute to use atomics; defaults to `Kokkos::Experimental::ScatterAtomic`, other option is `Kokkos::Experimental::ScatterNonAtomic`     |

#### Scatter operation

| Operation                           | Description   |
|-------------------------------------|---------------|
| `Kokkos::Experimental::ScatterSum`  | Sum           |
| `Kokkos::Experimental::ScatterProd` | Product       |
| `Kokkos::Experimental::ScatterMin`  | Minimum value |
| `Kokkos::Experimental::ScatterMax`  | Maximum value |

#### Scatter

```cpp
auto access = scatter.access();
```

#### Compute

```cpp
access(index) += value;
```

#### Gather

```cpp
Kokkos::Experimental::contribute(targetView, scatter);
```

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

#### Global fence

Wait for any asynchronous operation that was running before this command to finish.

```cpp
Kokkos::fence();
```

<!--#ifndef PRINT-->
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25">  https://kokkos.org/kokkos-core-wiki/API/core/parallel-dispatch/fence.html
<!--#endif-->

#### Execution space fence

Wait for any asynchronous operation of a specific execution space that was running before this command to finish.

```cpp
ExecutionSpace().fence();
```

<!--#ifndef PRINT-->
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://kokkos.org/kokkos-core-wiki/API/core/execution_spaces.html#functionality
<!--#endif-->

## Execution policy

Determines how the parallel execution should occur.

```cpp
ExecutionPolicy<ExecutionSpace, Schedule, IndexType, LaunchBounds, WorkTag> policy(/* ... */);
```

| Template argument | Description                                                                            |
|-------------------|----------------------------------------------------------------------------------------|
| `ExecutionSpace`  | See [execution spaces](#execution-spaces); defaults to `Kokkos::DefaultExecutionSpace` |
| `Schedule`        | How to schedule work items; defaults to machine and backend specifics                  |
| `IndexType`       | Integer type to be used for the index; defaults to `int64_t`                           |
| `LaunchBounds`    | Hints for CUDA and HIP launch bounds                                                   |
| `WorkTag`         | Empty tag class to call the functor                                                    |

<!--#ifndef PRINT-->
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://kokkos.org/kokkos-core-wiki/API/core/Execution-Policies.html
<!--#endif-->

### Ranges

#### One-dimensional range

```cpp
Kokkos::RangePolicy<ExecutionSpace, Schedule, IndexType LaunchBounds, WorkTag> policy(first, last);
```

If the ranges starts at index 0 and uses default template parameters, the entire execution policy can be replaced by an single integer which is the number of elements.

<!--#ifndef PRINT-->
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://kokkos.org/kokkos-core-wiki/API/core/policies/RangePolicy.html
<!--#endif-->

#### Multi-dimensional

By instance for dimension 2:

```cpp
Kokkos::MDRangePolicy<ExecutionSpace, Schedule, IndexType, LaunchBounds, WorkTag, Kokkos::Rank<2>> policy({firstI, firstJ}, {lastI, lastJ});
```

<!--#ifndef PRINT-->
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://kokkos.org/kokkos-core-wiki/API/core/policies/MDRangePolicy.html
<!--#endif-->

### Hierarchical parallelism

Kokkos supports hierarchical parallelism with a *league* of *teams*, using `Kokkos::TeamPolicy`.
Parallelisation within the team depends on the specific range policy used:

| Thread level        | Vector level        | Both levels           | Adequate for loops of dimension |
|---------------------|---------------------|-----------------------|---------------------------------|
| `TeamThreadRange`   | `TeamVectorRange`   |                       | 2                               |
| `TeamThreadMDRange` | `TeamVectorMDRange` | `ThreadVectorRange`   | 3                               |
| *same*              | *same*              | `ThreadVectorMDRange` | 4                               |

<!--#ifndef PRINT-->
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://kokkos.org/kokkos-core-wiki/ProgrammingGuide/HierarchicalParallelism.html
<!--#endif-->

#### Team policy

```cpp
Kokkos::TeamPolicy<ExecutionSpace, Schedule, IndexType, LaunchBounds, WorkTag> policy(numberOfTeams, /* numberOfElementsPerTeam = */ Kokkos::AUTO);
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
Kokkos::TeamThreadRange range(teamMember, firstJ, lastJ);
Kokkos::TeamVectorRange range(teamMember, firstJ, lastJ);
```

<!--#ifndef PRINT-->
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://kokkos.org/kokkos-core-wiki/API/core/policies/TeamThreadRange.html

<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://kokkos.org/kokkos-core-wiki/API/core/policies/TeamVectorRange.html
<!--#endif-->

##### Multi-dimensional team thread range or team vector range

By instance for dimension 2:

```cpp
Kokkos::TeamThreadMDRange<Kokkos::Rank<2>> range(teamMember, numberOfElementsJ, numberOfElementsK);
Kokkos::TeamVectorMDRange<Kokkos::Rank<2>> range(teamMember, numberOfElementsJ, numberOfElementsK);
```

<!--#ifndef PRINT-->
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://kokkos.org/kokkos-core-wiki/API/core/policies/TeamThreadMDRange.html

<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://kokkos.org/kokkos-core-wiki/API/core/policies/TeamVectorMDRange.html
<!--#endif-->

##### One-dimensional team thread vector range

```cpp
Kokkos::ThreadVectorRange range(teamMember, firstK, lastK);
```

<!--#ifndef PRINT-->
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://kokkos.org/kokkos-core-wiki/API/core/policies/ThreadVectorRange.html
<!--#endif-->

##### Multi-dimensional team thread vector range

By instance for dimension 2:

```cpp
Kokkos::ThreadVectorMDRange<Kokkos::Rank<2>> range(teamMember, numberOfElementsK, numberOfElementsL);
```

<!--#ifndef PRINT-->
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25">  https://kokkos.org/kokkos-core-wiki/API/core/policies/ThreadVectorMDRange.html
<!--#endif-->

## Scratch memory

Each team has access to a scratch memory pad, only accessible by its threads.
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
Note that not all functions are available.

<img title="Warning" alt="Warning" src="./images/warning_txt.svg" height="25"> Should be used on device prefixed by `Kokkos::`

| Function type    | List of available functions                                              |
|------------------|--------------------------------------------------------------------------|
| Basic operations | `abs`, `fabs`, `fmod`, `remainder`, `fma`, `fmax`, `fmin`, `fdim`, `nan` |
| Exponential      | `exp`, `exp2`, `expm1`, `log`, `log2`, `log10`, `log1p`                  |
| Power            | `pow`, `sqrt`, `cbrt`, `hypot`                                           |
| Trigonometric    | `sin`, `cos`, `tan`, `asin`, `acos`, `atan`, `atan2`                     |
| Hyperbolic       | `sinh`, `cosh`, `tanh`, `asinh`, `acosh`, `atanh`                        |
| Error and gamma  | `erf`, `erfc`, `tgamma`, `lgamma`                                        |
| Nearest          | `ceil`, `floor`, `trunc`, `round`, `nearbyint`                           |
| Floating point   | `logb`, `nextafter`, `copysign`                                          |
| Comparisons      | `isfinite`, `isinf`, `isnan`, `signbit`                                  |

<!--#ifndef PRINT-->
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://kokkos.org/kokkos-core-wiki/API/core/numerics/mathematical-functions.html?highlight=math
<!--#endif-->

### Complex numbers

#### Create

```cpp
Kokkos::complex<double> complex(realPart, imagPart);
```

#### Manage

| Methods  | Description                        |
|----------|------------------------------------|
| `real()` | Returns or sets the real part      |
| `imag()` | Returns or sets the imaginary part |

<!--#ifndef PRINT-->
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://kokkos.org/kokkos-core-wiki/API/core/utilities/complex.html
<!--#endif-->

## Utilities

<!--#ifndef PRINT-->
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://kokkos.org/kokkos-core-wiki/API/core/Utilities.html
<!--#endif-->

### Code interruption

Terminate the execution of a Kokkos program.

```cpp
Kokkos::abort("message");
```

### Print inside a kernel

Prints text to standard output.
The behavior is analogous to C++23 `std::print`; the return type is `void` to ensure a consistent behavior across backends.

```cpp
Kokkos::printf("format string", arg1, arg2);
```

### Timer

A simple timer class that can be used to measure the time taken by a block of code.

#### Create

```cpp
Kokkos::Timer timer;
```

#### Manage

| Methods     | Description                                                  |
|-------------|--------------------------------------------------------------|
| `seconds()` | Returns the time in seconds since construction or last reset |
| `reset()`   | Resets the timer to zero                                     |

### Manage parallel environment

| Functions               | Description                                                            |
|-------------------------|------------------------------------------------------------------------|
| `Kokkos::device_id()`   | Returns the device ID of the current device                            |
| `Kokkos::num_devices()` | Returns the number of devices available to the current execution space |
| `Kokkos::num_threads()` | Returns the number of threads in the current team                      |

## Macros

<!--#ifndef PRINT-->
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://kokkos.org/kokkos-core-wiki/API/core/Macros.html
<!--#endif-->

### Essential macros

| Macros                   | Description                                                                     |
|--------------------------|---------------------------------------------------------------------------------|
| `KOKKOS_LAMBDA`          | Replaces capture argument for lambdas                                           |
| `KOKKOS_FUNCTION`        | The method can be used in a Kokkos parallel construct                           |
| `KOKKOS_INLINE_FUNCTION` | The method can be used in a Kokkos parallel construct with the inline attribute |

### Extra macros

| Macros                 | Description                                                                           |
|------------------------|---------------------------------------------------------------------------------------|
| `KOKKOS_VERSION`       | Kokkos full version                                                                   |
| `KOKKOS_VERSION_MAJOR` | Kokkos major version                                                                  |
| `KOKKOS_VERSION_MINOR` | Kokkos minor version                                                                  |
| `KOKKOS_VERSION_PATCH` | Kokkos patch level                                                                    |
| `KOKKOS_ENABLE_*`      | Any equivalent CMake option passed when building Kokkos, see installation cheat sheet |
| `KOKKOS_ARCH_*`        | Any equivalent CMake option passed when building Kokkos, see installation cheat sheet |
