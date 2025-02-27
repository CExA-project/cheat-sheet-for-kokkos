---
title: Terminology cheat sheet for Kokkos
---

<!--#ifndef PRINT-->

# Terminology cheat sheet

<!--#endif-->

## Kokkos mapping

### Hierarchical parallelism

| Kokkos                                                                         | Cuda   | HIP               | SYCL       |
|--------------------------------------------------------------------------------|--------|-------------------|------------|
| `Kokkos::TeamPolicy</* ... */>(/* ... */)`                                     | Grid   | Grid, index range | ND-Range   | League
| `Kokkos::TeamPolicy</* ... */>::member_type(/* ... */)` (one-dimensional only) | Block  | Block, work group | Work-group | Team
| `Kokkos::TeamThread*Range(/* ... */)`                                          | Warp   | Warp, wavefront   | Sub-group  | SIMD chunk
| `Kokkos::TeamVector*Range(/* ... */)`, `Kokkos::ThreadVector*Range(/* ... */)` | Thread | Thread, work item | Work-item  | OpenMP thread, SIMD lane

<!--#ifndef PRINT-->
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://docs.nvidia.com/cuda/cuda-c-programming-guide/#thread-hierarchy
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://rocm.docs.amd.com/projects/HIP/en/develop/reference/kernel_language.html
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://www.intel.com/content/www/us/en/docs/oneapi/programming-guide/2025-0/sycl-thread-and-memory-hierarchy.html
<!--#endif-->

### Memory

| Kokkos                                        | Cuda                         | HIP                | SYCL                                       |
|-----------------------------------------------|------------------------------|--------------------|--------------------------------------------|
| `Kokkos::DefaultExecutionSpace::memory_space` | Global memory                | Global memory      | Global memory                              |
| `Kokkos::ScratchMemorySpace` (space level 0)  | Shared memory                | Shared memory      | (Shared) local memory?                     |
| `Kokkos::ScratchMemorySpace` (space level 1)  | Global memory                | Global memory      | Global memory?                             |
| `Kokkos::SharedHostPinnedSpace`               | Pinned host memory           | Pinned host memory | Unified shared memory (USM) of type host   |
| `Kokkos::SharedSpace`                         | Unified virtual memory (UVM) | Unified memory     | Unified shared memory (USM) of type shared |

<!--#ifndef PRINT-->
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://docs.nvidia.com/cuda/cuda-c-programming-guide/#memory-hierarchy
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://rocm.docs.amd.com/projects/HIP/en/docs-develop/how-to/hip_runtime_api/memory_management/device_memory.html
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://www.intel.com/content/www/us/en/docs/oneapi/programming-guide/2025-0/sycl-thread-and-memory-hierarchy.html
<!--#endif-->

### Execution

| Kokkos                                        | Cuda                         | HIP                | SYCL                               |
|-----------------------------------------------|------------------------------|--------------------|------------------------------------|
| `Kokkos::DefaultExecutionSpace()`             | Stream                       | Stream             | Queue                              |

## GPU terminology equivalences

| Cuda on NVIDIA                | HIP on AMD         | SYCL/OpenCL on Intel | Notes                   |
|-------------------------------|--------------------|----------------------|-------------------------|
| Streaming multiprocessor (SM) | Compute unit (CU)  | Compute unit         |                         |
| Streaming processor           | Processing element | Processing element   |                         |
| Warp                          | Wavefront, warp    | Sub-group            |                         |
| Thread                        | Work item          | Work-item            |                         |
| NVPTX                         | AMDIL              | SPIR-V               | Not strictly equivalent |

