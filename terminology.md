---
title: Terminology cheat sheet for Kokkos
---

<!--#ifndef PRINT-->

# Terminology cheat sheet

<!--#endif-->

## Memory

| Kokkos                                        | Cuda                         | HIP                | SYCL                        |
|-----------------------------------------------|------------------------------|--------------------|-----------------------------|
| `Kokkos::DefaultExecutionSpace::memory_space` | Global memory                | Global memory      | Global memory               |
| `Kokkos::ScratchMemorySpace`                  | Shared memory                | Shared memory      | (Shared) local memory       |
| --                                            | Local memory                 | Local memory       | --                          |
| --                                            | Register                     | Register           | Private memory              |
| `Kokkos::SharedHostPinnedSpace`               | Pinned host memory           | Pinned host memory | Host unified shared memory  |
| `Kokkos::SharedSpace`                         | Unified virtual memory (UVM) | Unified memory     | Unified shared memory (USM) |

<!--#ifndef PRINT-->
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://rocm.docs.amd.com/projects/HIP/en/docs-develop/how-to/hip_runtime_api/memory_management/device_memory.html
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://rocm.docs.amd.com/projects/HIP/en/latest/how-to/performance_guidelines.html
<!--#endif-->

## Execution

| Cuda on NVIDIA                | HIP on AMD         | SYCL/OpenCL on Intel | Notes                   |
|-------------------------------|--------------------|----------------------|-------------------------|
| Streaming multiprocessor (SM) | Compute unit (CU)  | Compute unit         |                         |
| Streaming processor           | Processing element | Processing element   |                         |
| Warp                          | Wavefront          | Sub group            |                         |
| Thread                        | Work item          | Work item            |                         |
| NVPTX                         | AMDIL              | SPIR                 | Not strictly equivalent |

## Hierarchical parallelism

| Kokkos | OpenMP target | OpenACC        | Cuda   | HIP         | SYCL       |
|--------|---------------|----------------|--------|-------------|------------|
| League | League        | --             | Grid   | Index range | ND-range   |
| Team   | Team          | Gang           | Block  | Work group  | Work group |
| Thread | --            | --             | Warp   | Wavefront   | Sub group  |
| Vector | Thread        | Worker, Vector | Thread | Work item   | Work item  |

<!--#ifndef PRINT-->
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> https://www.intel.com/content/www/us/en/docs/oneapi/optimization-guide-gpu/2023-0/sycl-thread-mapping-and-gpu-occupancy.html
<!--#endif-->
