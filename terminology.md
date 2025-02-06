---
title: Terminology cheat sheet for Kokkos
---

<!--#ifndef PRINT-->

# Terminology cheat sheet

<!--#endif-->

## Memory

| Kokkos             | Cuda           | HIP           | SYCL         |
|--------------------|----------------|---------------|--------------|
|                    | Global memory  |               |              |
|                    | Texture memory |               |              |
| Scratch pad memory | Shared memory  | Shared memory | Local memory |
|                    | Local memory   |               |              |
|                    | Register       |               |              |

## Execution

| Kokkos        | Cuda                     | HIP          | SYCL |
|---------------|--------------------------|--------------|------|
| Core clusters | Streaming multiprocessor | Compute unit |      |
|               | Streaming processor      |              |      |
|               | Warp                     | Wavefront    |      |

## Hierarchical parallelism

| Kokkos | Cuda  | HIP              | SYCL       |
|--------|-------|------------------|------------|
| League | Grid  |                  |            |
| Team   | Block | Work group/block | Work group |
| Thread |       |                  |            |
