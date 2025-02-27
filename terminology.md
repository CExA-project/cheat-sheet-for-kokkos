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
| `Kokkos::TeamPolicy</* ... */>(/* ... */)`                                     | Grid   | Grid, index range | ND-Range   |
| `Kokkos::TeamPolicy</* ... */>::member_type(/* ... */)` (one-dimensional only)                       | Block  | Block, work group | Work-group |
| `Kokkos::TeamThread*Range(/* ... */)`                                          | Warp   | Warp, wavefront   | Sub-group  |
| `Kokkos::TeamVector*Range(/* ... */)`, `Kokkos::ThreadVector*Range(/* ... */)` | Thread | Thread, work item | Work-item  |

<!--#ifndef PRINT-->
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://docs.nvidia.com/cuda/cuda-c-programming-guide/#programming-model
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://rocm.docs.amd.com/projects/HIP/en/develop/reference/kernel_language.html
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://www.intel.com/content/www/us/en/docs/oneapi/optimization-guide-gpu/2023-0/sycl-thread-mapping-and-gpu-occupancy.html
<!--#endif-->

### Memory

| Kokkos                                        | Cuda                         | HIP                | SYCL                                       |
|-----------------------------------------------|------------------------------|--------------------|--------------------------------------------|
| `Kokkos::DefaultExecutionSpace::memory_space` | Global memory                | Global memory      | Global memory                              |
| `Kokkos::ScratchMemorySpace` (with level 0)   | Shared memory                | Shared memory      | (Shared) local memory                      |
| `Kokkos::SharedHostPinnedSpace`               | Pinned host memory           | Pinned host memory | Unified shared memory (USM) of type host   |
| `Kokkos::SharedSpace`                         | Unified virtual memory (UVM) | Unified memory     | Unified shared memory (USM) of type shared |

### Execution

| Kokkos                                        | Cuda                         | HIP                | SYCL                               |
|-----------------------------------------------|------------------------------|--------------------|------------------------------------|
| `Kokkos::DefaultExecutionSpace()`             | Stream                       | Stream             | Queue                              |

<!--#ifndef PRINT-->
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://rocm.docs.amd.com/projects/HIP/en/docs-develop/how-to/hip_runtime_api/memory_management/device_memory.html
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://rocm.docs.amd.com/projects/HIP/en/latest/how-to/performance_guidelines.html
<!--#endif-->

## GPU terminology

| Cuda on NVIDIA                | HIP on AMD         | SYCL/OpenCL on Intel | Notes                   |
|-------------------------------|--------------------|----------------------|-------------------------|
| Streaming multiprocessor (SM) | Compute unit (CU)  | Compute unit         |                         |
| Streaming processor           | Processing element | Processing element   |                         |
| Warp                          | Wavefront, warp    | Sub-group            |                         |
| Thread                        | Work item          | Work-item            |                         |
| NVPTX                         | AMDIL              | SPIR-V               | Not strictly equivalent |

