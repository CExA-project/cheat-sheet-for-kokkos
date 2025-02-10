---
title: Terminology cheat sheet for Kokkos
---

<!--#ifndef PRINT-->

# Terminology cheat sheet

<!--#endif-->

## Memory

| Kokkos                           | Cuda                         | HIP                | SYCL                        |
|----------------------------------|------------------------------|--------------------|-----------------------------|
| Default execution space's memory | Global memory                | Global memory      | Global memory               |
| Default execution space's memory | Texture memory               | Texture memory     | Image memory                |
| Scratch pad memory               | Shared memory                | Shared memory      | (Shared) local memory       |
|                                  | Local memory                 | Local memory       |                             |
|                                  | Register                     | Register           | Private memory              |
| Shared host pinned memory        | Pinned host memory           | Pinned host memory | Host unified shared memory  |
| Shared memory                    | Unified virtual memory (UVM) | Unified memory     | Unified shared memory (USM) |

<!--#ifndef PRINT-->
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> ttps://rocm.docs.amd.com/projects/HIP/en/docs-develop/how-to/hip_runtime_api/memory_management/device_memory.html
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> ttps://rocm.docs.amd.com/projects/HIP/en/latest/how-to/performance_guidelines.html
<!--#endif-->

## Execution

| CPU          | NVIDIA                        | AMD                | Intel Xe-HPC  | SYCL               |
|--------------|-------------------------------|--------------------|---------------|--------------------|
| Core cluster | Streaming multiprocessor (SM) | Compute unit (CU)  | Xe core       | Compute unit       |
| Core         | Streaming processor           | Processing element | Vector engine | Processing element |
| Vector?      | Warp                          | Wavefront          | SIMD?         | Sub group          |
| Vector lane  | Thread                        | Work item          |               | Work item          |
|              | NVPTX                         | AMDIL              | SPIR          |                    |
| Loop body    | Kernel                        | Kernel             | Kernel        | Kernel             |

## Hierarchical parallelism

| Kokkos | OpenMP target | OpenACC | Cuda   | HIP         | SYCL       |
|--------|---------------|---------|--------|-------------|------------|
| Team   | Team          | Gang    | Grid   | Index range | ND-range   |
| Thread | Thread        | Worker  | Block  | Work group  | Work group |
| Vector | SIMD          | Vector  | Thread | Work item   | Work item  |

<!--#ifndef PRINT-->
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> ttps://www.intel.com/content/www/us/en/docs/oneapi/optimization-guide-gpu/2023-0/sycl-thread-mapping-and-gpu-occupancy.html
<img title="Doc" alt="Doc" src="./images/doc_txt.svg" height="25"> ttps://www.intel.com/content/www/us/en/docs/oneapi/optimization-guide-gpu/2023-0/sycl-thread-mapping-and-gpu-occupancy.html
<!--#endif-->
