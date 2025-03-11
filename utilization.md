---
title: Utilisation cheat sheet for Kokkos
---

<!--#ifndef PRINT-->

# Kokkos utilization cheat sheet

<img title="Warning" alt="Warning" src="./images/warning_txt.svg" height="25"> Only for Kokkos 4.5 and more, for older version look at the doc.

<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://kokkos.org/kokkos-core-wiki/programmingguide.html

<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://kokkos.org/kokkos-core-wiki/API/core-index.html

<img title="Doc" alt="Doc" src="./images/tutorial_txt.svg" height="25"> https://github.com/kokkos/kokkos-tutorials/blob/main/LectureSeries/KokkosTutorial_01_Introduction.pdf

<!--#endif-->

## Header

```cpp
#include <Kokkos_Core.hpp>
```

## Initialization

### Initialize and finalize

```cpp
int main(int argc, char* argv[]) {
    Kokkos::initialize(argc, argv);
    { /* ... */ }
    Kokkos::finalize();
}
```

### Scope guard

```cpp
int main(int argc, char* argv[]) {
    Kokkos::ScopeGuard kokkos(argc, argv);
    /* ... */
}
```

## Kokkos concepts

### Execution spaces

| Execution space                     | Device backend | Host backend |
|-------------------------------------|----------------|--------------|
| `Kokkos::DefaultExecutionSpace`     | On device      | On host      |
| `Kokkos::DefaultHostExecutionSpace` | On host        | On host      |

<!--#ifndef PRINT-->
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://kokkos.org/kokkos-core-wiki/API/core/execution_spaces.html
<!--#endif-->

### Memory spaces

<!--#ifndef PRINT-->
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://kokkos.org/kokkos-core-wiki/API/core/memory_spaces.html
<!--#endif-->

#### Generic memory spaces

| Memory space                                      | Device backend | Host backend |
|---------------------------------------------------|----------------|--------------|
| `Kokkos::DefaultExecutionSpace::memory_space`     | On device      | On host      |
| `Kokkos::DefaultHostExecutionSpace::memory_space` | On host        | On host      |

#### Specific memory spaces

| Memory space                    | Description                                                               |
|---------------------------------|---------------------------------------------------------------------------|
| `Kokkos::HostSpace`             | Accessible from the host but maybe not from the device                    |
| `Kokkos::SharedSpace`           | Accessible from the host and the device; copy managed by the driver       |
| `Kokkos::SharedHostPinnedSpace` | Accessible from the host and the device; zero copy access in small chunks |

<!--#ifndef PRINT-->
<details>
<summary>Examples</summary>

```cpp
// Host space
Kokkos::View<double*, Kokkos::HostSpace> hostView("hostView", numberOfElements);

// Shared space
Kokkos::View<double*, Kokkos::SharedSpace> sharedView("sharedView", numberOfElements);

// Shared host pinned space
Kokkos::View<double*, Kokkos::SharedHostPinnedSpace> sharedHostPinnedView("sharedHostPinnedView", numberOfElements);
```

</details>
<!--#endif-->

## Memory management

### View

<!--#ifndef PRINT-->
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://kokkos.org/kokkos-core-wiki/API/core/view/view.html
<!--#endif-->

#### Create

```cpp
Kokkos::View<DataType, LayoutType, MemorySpace, MemoryTraits> view("label", numberOfElementsAtRuntimeI, numberOfElementsAtRuntimeJ);
```

| Template argument | Description                                                                                                                                                  |
|-------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `DataType`        | `ScalarType` for the data type, followed by a `*` for each runtime dimension, then by a `[numberOfElements]` for each compile time dimension, mandatory |
| `LayoutType`      | See [memory layouts](#memory-layouts), optional                                                                                                              |
| `MemorySpace`     | See [memory spaces](#memory-spaces), optional                                                                                                                |
| `MemoryTraits`    | See [memory traits](#memory-traits), optional                                                                                                                |

<img title="Warning" alt="Warning" src="./images/warning_txt.svg" height="25"> The order of template arguments is important.

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

#### Manage

| Method        | Description                                               |
|---------------|-----------------------------------------------------------|
| `(i, j...)`   | Returns and sets the value at index `i`, `j`, etc.        |
| `size()`      | Returns the total number of elements in the view          |
| `rank()`      | Returns the number of dimensions                          |
| `layout()`    | Returns the layout of the view                            |
| `extent(dim)` | Returns the number of elements in the requested dimension |
| `data()`      | Returns a pointer to the underlying data                  |

<!--#ifndef PRINT-->
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://kokkos.org/kokkos-core-wiki/API/core/view/view.html#data-access-functions

<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://kokkos.org/kokkos-core-wiki/API/core/view/view.html#data-layout-dimensions-strides
<!--#endif-->

###### Resize and preserve content

```cpp
Kokkos::resize(view, newNumberOfElementsI, newNumberOfElementsJ...);
```

<!--#ifndef PRINT-->
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://kokkos.org/kokkos-core-wiki/API/core/view/resize.html
<!--#endif-->

###### Reallocate and do not preserve content

```cpp
Kokkos::realloc(view, newNumberOfElementsI, newNumberOfElementsJ...);
```

<!--#ifndef PRINT-->
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://kokkos.org/kokkos-core-wiki/API/core/view/realloc.html
<!--#endif-->

### Memory Layouts

| Layout                 | Description                                                                                                 | Default |
|------------------------|-------------------------------------------------------------------------------------------------------------|---------|
| `Kokkos::LayoutRight`  | Strides increase from the right most to the left most dimension, also known as row-major or C-like          | CPU     |
| `Kokkos::LayoutLeft`   | Strides increase from the left most to the right most dimension, also known as column-major or Fortran-like | GPU     |
| `Kokkos::LayoutStride` | Strides can be arbitrary for each dimension                                                                 |         |

By default, a layout suited for loops on the high frequency index is used.

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

Memory traits are indicated with `Kokkos::MemoryTraits<>` and are combined with the `|` (pipe) operator.

| Memory trait           | Description                                                                                                                               |
|------------------------|-------------------------------------------------------------------------------------------------------------------------------------------|
| `Kokkos::Unmanaged`    | The allocation has to be managed manually                                                                                                 |
| `Kokkos::Atomic`       | All accesses to the view are atomic                                                                                                       |
| `Kokkos::RandomAccess` | Hint that the view is used in a random access manner; if the view is also `const` this may trigger more efficient load operations on GPUs |
| `Kokkos::Restrict`     | There is no aliasing of the view by other data structures in the current scope                                                            |

<!--#ifndef PRINT-->
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://kokkos.org/kokkos-core-wiki/ProgrammingGuide/View.html#access-traits

<details>
<summary>Examples</summary>

```cpp
// Unmanaged view on CPU
double* data = new double[numberOfElements];
Kokkos::View<double*, Kokkos::HostSpace, Kokkos::MemoryTraits<Kokkos::Unmanaged>> unmanagedView(data, numberOfElements);

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

<!--#ifndef PRINT-->
<img title="Warning" alt="Warning" src="./images/warning_txt.svg" height="25"> Copying or assigning a view does a shallow copy, data are not synchronized in this case.
<!--#endif-->

```cpp
Kokkos::deep_copy(dest, src);
```

The views must have the same dimensions, data type, and reside in the same memory space ([mirror views](#mirror-view) can be deep copied on different memory spaces).

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

<!--#ifndef PRINT-->
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://kokkos.org/kokkos-core-wiki/API/core/view/create_mirror.html

<img title="Code" alt="Code" src="./images/code_txt.svg" height="25">

- [Kokkos example - simple memoryspace](https://github.com/kokkos/kokkos/blob/master/example/tutorial/04_simple_memoryspaces/simple_memoryspaces.cpp)
- [Kokkos Tutorials - Exercise 3](https://github.com/kokkos/kokkos-tutorials/blob/main/Exercises/03/Solution/exercise_3_solution.cpp)
<!--#endif-->

#### Create and always allocate on host

```cpp
auto mirrorView = Kokkos::create_mirror(view);
```

#### Create and allocate on host if source view is not in host space

```cpp
auto mirrorView = Kokkos::create_mirror_view(view);
```

#### Create, allocate and synchronize if source view is not in same space as destination view

```cpp
auto mirrorView = Kokkos::create_mirror_view_and_copy(ExecutionSpace(), view);
```

### Subview

A subview has the same reference count as its parent view, so the parent view won't be deallocated before all subviews go away.

<!--#ifndef PRINT-->
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://kokkos.org/kokkos-core-wiki/API/core/view/subview.html

<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://kokkos.org/kokkos-core-wiki/ProgrammingGuide/Subviews.html
<!--#endif-->

```cpp
auto subview = Kokkos::subview(view, selector1, selector2, ...);
```

| Subset selector             | Description                         |
|-----------------------------|-------------------------------------|
| `Kokkos::ALL`               | All elements in this dimension      |
| `Kokkos::pair(first, last)` | Range of elements in this dimension |
| `value`                     | Specific element in this dimension  |

### Scatter view (experimental)

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
auto scatterView = Kokkos::Experimental::create_scatter_view<Operation, Duplication, Contribution>(targetView);
```

| Template argument | Description                                                                                                                                                 |
|-------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `Operation`       | See [scatter operation](#scatter-operation); defaults to `Kokkos::Experimental::ScatterSum`                                                                 |
| `Duplication`     | Whether to duplicate the grid or not; choices are `Kokkos::Experimental::ScatterDuplicated`, and `Kokkos::Experimental::ScatterNonDuplicated`; defaults to the option that is the most optimised for `targetView`'s execution space |
| `Contribution`    | Whether to contribute using atomics or not; choices are `Kokkos::Experimental::ScatterAtomic`, or `Kokkos::Experimental::ScatterNonAtomic`; defaults to the option that is the most optimised for `targetView`'s execution space |

#### Scatter operation

| Operation                           | Description   |
|-------------------------------------|---------------|
| `Kokkos::Experimental::ScatterSum`  | Sum           |
| `Kokkos::Experimental::ScatterProd` | Product       |
| `Kokkos::Experimental::ScatterMin`  | Minimum value |
| `Kokkos::Experimental::ScatterMax`  | Maximum value |

#### Scatter, compute, and gather

```cpp
Kokkos::parallel_for(
    "label",
    /* ... */,
    KOKKOS_LAMBDA (/* ... */) {
        // scatter
        auto scatterAccess = scatterView.access();

        // compute
        scatterAccess(/* index */) /* operation */ /* contribution */;
    }
);

// gather
Kokkos::Experimental::contribute(targetView, scatterView);
```

<!--#ifndef PRINT-->
<details>
<summary>Full example</summary>

```cpp
#include<Kokkos_ScatterView.hpp>

// Compute histogram of values in view1D
KOKKOS_INLINE_FUNCTION int getIndex(double position) { /* ... */ }
KOKKOS_INLINE_FUNCTION double compute(double weight) { /* ... */ }

// Views of 100 elements to process
Kokkos::View<double*> position("position", 100);
Kokkos::View<double*> weight("weight", 100);

// Histogram of 10 slots
Kokkos::View<double*> histogram("bar", 10);
auto histogramScatter = Kokkos::Experimental::create_scatter_view(histogram);

Kokkos::parallel_for(
    100,
    KOKKOS_LAMBDA (const int i) {
        // scatter
        auto access = histogramScatter.access();

        // compute
        const auto index = getIndex(position(i));
        const auto contribution = compute(weight(i));
        access(index) += contribution;
    }
);

// gather
Kokkos::Experimental::contribute(histogram, histogramScatter);
```

</details>
<!--#endif-->

## Parallel constructs

### For loop

```cpp
Kokkos::parallel_for(
    "label",
    ExecutionPolicy</* ... */>(/* ... */),
    KOKKOS_LAMBDA (/* ... */) { /* ... */ }
);
```

### Reduction

```cpp
ScalarType result;
Kokkos::parallel_reduce(
    "label",
    ExecutionPolicy</* ... */>(/* ... */),
    KOKKOS_LAMBDA (/* ... */, ScalarType& resultLocal) { /* ... */ },
    Kokkos::ReducerConcept<ScalarType>(result)
);
```

With `Kokkos::ReducerConcept` being one of the following:

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
| `Kokkos::MinMax`    | `std::minmax`         | Minimum and maximum                        |
| `Kokkos::MinMaxLoc` | `std::minmax_element` | Minimum and maximum and associated indices |
| `Kokkos::Prod`      | `*`                   | Product                                    |
| `Kokkos::Sum`       | `+`                   | Sum                                        |

A scalar value may be passed, for which the reduction is limited to a sum.
When using the `TeamVectorMDRange`, the `TeamThreadMDRange`, or the `ThreadVectorMDRange` execution policy, only a scalar value may be passed, for which the reduction is also limited to a sum.

<!--#ifndef PRINT-->
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://kokkos.org/kokkos-core-wiki/API/core/parallel-dispatch/parallel_reduce.html

<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://kokkos.org/kokkos-core-wiki/API/core/builtin_reducers.html
<!--#endif-->

### Fences

#### Global fence

```cpp
Kokkos::fence("label");
```

<!--#ifndef PRINT-->
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25">  https://kokkos.org/kokkos-core-wiki/API/core/parallel-dispatch/fence.html
<!--#endif-->

#### Execution space fence

```cpp
ExecutionSpace().fence("label");
```

#### Team barrier

```cpp
Kokkos::TeamPolicy<>::member_type().team_barrier();
```

<!--#ifndef PRINT-->
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://kokkos.org/kokkos-core-wiki/API/core/execution_spaces.html#functionality
<!--#endif-->

## Execution policy

### Create

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

If the range starts at 0 and uses default parameters, can be replaced by just the number of elements.

<!--#ifndef PRINT-->
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://kokkos.org/kokkos-core-wiki/API/core/policies/RangePolicy.html
<!--#endif-->

#### Multi-dimensional (dimension 2)

```cpp
Kokkos::MDRangePolicy<ExecutionSpace, Schedule, IndexType, LaunchBounds, WorkTag, Kokkos::Rank<2>> policy({firstI, firstJ}, {lastI, lastJ});
```

<!--#ifndef PRINT-->
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://kokkos.org/kokkos-core-wiki/API/core/policies/MDRangePolicy.html
<!--#endif-->

### Hierarchical parallelism

<!--#ifndef PRINT-->
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://kokkos.org/kokkos-core-wiki/ProgrammingGuide/HierarchicalParallelism.html
<!--#endif-->

#### Team policy

```cpp
Kokkos::TeamPolicy<ExecutionSpace, Schedule, IndexType, LaunchBounds, WorkTag> policy(leagueSize, teamSize);
```

Usually, `teamSize` is replaced by `Kokkos::AUTO` to let Kokkos determine it.
A kernel running in a team policy has a `Kokkos::TeamPolicy<>::member_type` argument:

| Method          | Description                         |
|-----------------|-------------------------------------|
| `league_size()` | Number of teams in the league       |
| `league_rank()` | Index of the team within the league |
| `team_size()`   | Number of threads in the team       |
| `team_rank()`   | Index of the thread within the team |

Note that nested parallel constructs do not use `KOKKOS_LAMBDA` but `[=]`.

<!--#ifndef PRINT-->
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://kokkos.org/kokkos-core-wiki/API/core/policies/TeamPolicy.html
<!--#endif-->

#### Team vector level (2-level hierarchy)

```cpp
Kokkos::parallel_for(
    "label",
    Kokkos::TeamPolicy(numberOfElementsI, Kokkos::AUTO),
    KOKKOS_LAMBDA (const Kokkos::TeamPolicy<>::member_type& teamMember) {
        const int i = teamMember.team_rank();

        Kokkos::parallel_for(
            Kokkos::TeamVectorRange(teamMember, firstJ, lastJ),
            [=] (const int j) { /* ... */ }
        );
    }
);
```

##### One-dimensional range

```cpp
Kokkos::TeamVectorRange range(teamMember, firstJ, lastJ);
```

<!--#ifndef PRINT-->
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://kokkos.org/kokkos-core-wiki/API/core/policies/TeamVectorRange.html
<!--#endif-->

##### Multi-dimensional range (dimension 2)

```cpp
Kokkos::TeamVectorMDRange<Kokkos::Rank<2>, Kokkos::TeamPolicy<>::member_type> range(teamMember, numberOfElementsJ, numberOfElementsK);
```

<!--#ifndef PRINT-->
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://kokkos.org/kokkos-core-wiki/API/core/policies/TeamVectorMDRange.html
<!--#endif-->

#### Team thread vector level (3-level hierarchy)

```cpp
Kokkos::parallel_for(
    "label",
    Kokkos::TeamPolicy(numberOfElementsI, Kokkos::AUTO),
    KOKKOS_LAMBDA (const Kokkos::TeamPolicy<>::member_type& teamMember) {
        const int i = teamMember.team_rank();

        Kokkos::parallel_for(
            Kokkos::TeamThreadRange(teamMember, firstJ, lastJ),
            [=] (const int j) {
                Kokkos::parallel_for(
                    Kokkos::ThreadVectorRange(teamMember, firstK, lastK),
                    [=] (const int k) { /* ... */ }
                );
            }
        );
    }
);
```

##### One-dimensional range

```cpp
Kokkos::TeamThreadRange range(teamMember, firstJ, lastJ);
Kokkos::ThreadVectorRange range(teamMember, firstK, lastK);
```

<!--#ifndef PRINT-->
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://kokkos.org/kokkos-core-wiki/API/core/policies/TeamThreadRange.html

<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://kokkos.org/kokkos-core-wiki/API/core/policies/ThreadVectorRange.html
<!--#endif-->

##### Multi-dimensional range (dimension 2)

```cpp
Kokkos::TeamThreadMDRange<Kokkos::Rank<2>, Kokkos::TeamPolicy<>::member_type> range(teamMember, numberOfElementsJ, numberOfElementsK);
Kokkos::ThreadVectorMDRange<Kokkos::Rank<2>, Kokkos::TeamPolicy<>::member_type> range(teamMember, numberOfElementsL, numberOfElementsM);
```

<!--#ifndef PRINT-->
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://kokkos.org/kokkos-core-wiki/API/core/policies/TeamThreadMDRange.html

<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25">  https://kokkos.org/kokkos-core-wiki/API/core/policies/ThreadVectorMDRange.html
<!--#endif-->

## Scratch memory

Each team has access to a scratch memory pad, which has the team's lifetime, and is only accessible by the team's threads.

<!--#ifndef PRINT-->
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25">  https://kokkos.org/kokkos-core-wiki/ProgrammingGuide/HierarchicalParallelism.html#team-scratch-pad-memory
<!--#endif-->

### Scratch memory space

| Space level | Memory size                 | Access speed |
|-------------|-----------------------------|--------------|
| 0           | Limited (tens of kilobytes) | Fast         |
| 1           | Larger (few gigabytes)      | Medium       |

Used when passing the team policy to the parallel construct and when creating the scratch memory pad.

### Create and populate

```cpp
// Define a scratch memory pad type
using ScratchPad = Kokkos::View<DataType, Kokkos::DefaultExecutionSpace::scratch_memory_space, Kokkos::MemoryTraits<Kokkos::Unmanaged>>;

// Compute how much scratch memory is needed (in bytes)
size_t bytes = ScratchPad::shmem_size(vectorSize);

// Create the team policy and specify the total scratch memory needed
Kokkos::parallel_for(
    "label",
    Kokkos::TeamPolicy<>(leagueSize, teamSize).set_scratch_size(spaceLevel, Kokkos::PerTeam(bytes)),
    KOKKOS_LAMBDA (const Kokkos::TeamPolicy<>::member_type& teamMember) {
        const int i = teamMember.league_rank();

        // Create the scratch pad
        ScratchPad scratch(teamMember.team_scratch(spaceLevel), vectorSize);

        // Initialize it
        Kokkos::parallel_for(
            Kokkos::TeamVectorRange(teamMember, vectorSize),
            [=] (const int j) { scratch(j) = getScratchData(i, j); }
        );

        // Synchronize
        teamMember.team_barrier();
    }
);
```

## Atomics
  
<!--#ifndef PRINT-->
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://kokkos.org/kokkos-core-wiki/ProgrammingGuide/Atomic-Operations.html

<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://kokkos.org/kokkos-core-wiki/API/core/atomics.html
<!--#endif-->

### Atomic operations

| Operation                      | Replaces             |
|--------------------------------|----------------------|
| `Kokkos::atomic_add(&x, y)`    | `x += y`             |
| `Kokkos::atomic_and(&x, y)`    | `x &= y`             |
| `Kokkos::atomic_dec(&x)`       | `x--`                |
| `Kokkos::atomic_inc(&x)`       | `x++`                |
| `Kokkos::atomic_lshift(&x, y)` | `x = x << y`         |
| `Kokkos::atomic_max(&x, y)`    | `x = std::max(x, y)` |
| `Kokkos::atomic_min(&x, y)`    | `x = std::min(x, y)` |
| `Kokkos::atomic_mod(&x, y)`    | `x %= y`           |
| `Kokkos::atomic_nand(&x, y)`   | `x = !(x && y)`      |
| `Kokkos::atomic_or(&x, y)`     | `x \|= y`            |
| `Kokkos::atomic_rshift(&x, y)` | `x = x >> y`         |
| `Kokkos::atomic_sub(&x, y)`    | `x -= y`             |
| `Kokkos::atomic_store(&x, y)`  | `x = y`              |
| `Kokkos::atomic_xor(&x, y)`    | `x ^= y`             |

<!--#ifndef PRINT-->
<details>
<summary>Example</summary>

```cpp
Kokkos::parallel_for(
    numberOfElements,
    KOKKOS_LAMBDA (const int i) {
        const int value = /* ... */;
        const int bucketIndex = computeBucketIndex (value);
        Kokkos::atomic_inc(&histogram(bucketIndex));
    }
);
```

</details>
<!--#endif-->

### Atomic exchanges

| Operation                                                | Description                                                                                  |
|----------------------------------------------------------|----------------------------------------------------------------------------------------------|
| `Kokkos::atomic_exchange(&x, desired)`                   | Assign desired value to object and return old value                                          |
| `Kokkos::atomic_compare_exchange(&x, expected, desired)` | Assign desired value to object if the object has the expected value and return the old value |

<!--#ifndef PRINT-->
<details>
<summary>Example</summary>

```cpp
// Assign desired value to object and return old value
int desired = 20;
int obj = 10;
int old = Kokkos::atomic_exchange(&obj, desired);

// Assign desired value to object if the object has the expected value and return the old value
int desired = 20;
int obj = 10;
int expected = 10;
int old = atomic_compare_exchange(&obj, expected, desired);
```

</details>
<!--#endif-->

## Mathematics

### Math functions

| Function type    | List of functions (prefixed by `Kokkos::`)                               |
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

Note that not all C++ standard math functions are available.

<!--#ifndef PRINT-->
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://kokkos.org/kokkos-core-wiki/API/core/numerics/mathematical-functions.html?highlight=math
<!--#endif-->

### Complex numbers

#### Create

```cpp
Kokkos::complex<double> complex(realPart, imagPart);
```

#### Manage

| Method   | Description                        |
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

```cpp
Kokkos::abort("message");
```

### Print inside a kernel

```cpp
Kokkos::printf("format string", arg1, arg2);
```

Similar to `std::printf`.

### Timer

#### Create

```cpp
Kokkos::Timer timer;
```

#### Manage

| Method      | Description                                                  |
|-------------|--------------------------------------------------------------|
| `seconds()` | Returns the time in seconds since construction or last reset |
| `reset()`   | Resets the timer to zero                                     |

### Manage parallel environment

| Function                | Description                                                            |
|-------------------------|------------------------------------------------------------------------|
| `Kokkos::device_id()`   | Returns the device ID of the current device                            |
| `Kokkos::num_devices()` | Returns the number of devices available to the current execution space |

## Macros

<!--#ifndef PRINT-->
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://kokkos.org/kokkos-core-wiki/API/core/Macros.html
<!--#endif-->

### Essential macros

| Macro                    | Description                                            |
|--------------------------|--------------------------------------------------------|
| `KOKKOS_LAMBDA`          | Replaces capture argument for lambdas                  |
| `KOKKOS_CLASS_LAMBDA`    | Replaces capture argument for lambdas, captures `this` |
| `KOKKOS_FUNCTION`        | Functor attribute                                      |
| `KOKKOS_INLINE_FUNCTION` | Inlined functor attribute                              |

### Extra macros

| Macro                  | Description                                                                           |
|------------------------|---------------------------------------------------------------------------------------|
| `KOKKOS_VERSION`       | Kokkos full version                                                                   |
| `KOKKOS_VERSION_MAJOR` | Kokkos major version                                                                  |
| `KOKKOS_VERSION_MINOR` | Kokkos minor version                                                                  |
| `KOKKOS_VERSION_PATCH` | Kokkos patch level                                                                    |
| `KOKKOS_ENABLE_*`      | Any equivalent CMake option passed when building Kokkos, see installation cheat sheet |
| `KOKKOS_ARCH_*`        | Any equivalent CMake option passed when building Kokkos, see installation cheat sheet |
