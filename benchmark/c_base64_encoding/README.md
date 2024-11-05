# C Base64 Encode Benchmarks

## Overview

This benchmark serves to compare approaches to allocated encoded buffers for
base64 in C.

Base64 encoded converts chunks of 3 bytes into chunks of 4 bytes, padding the
last chunk.

This means the precise encoded size calculation looks something like:

`X * 4/3 + P`

Where `P` is some amount of padding such that the final encoded size is an even
multiple of 4. The final size increase is 33-37%.

## Simplifications

There are two main simplifications/optimizations we can make:

- Always add the maximum padding amount
- Calculate at 50% to simplify the division

### Max padding

By always making space for max padding (3 bytes) we no longer require any
additional checks, but at the cost of 3 bytes per allocation.

Then the calculation is `X * 4/3 + 3`, this ensures enough bytes are allocated
to hold the encoding buffer without needing to check.

### Calculate at 50%

Calculating at 50% wastes 13-17% memory, but allows us to simplify the division.
Dividing by 2 can be optimized as a bit shift when working with positive numbers
and has even larger potential compute savings at the cost of even more memory.

## Benchmark

This bench mark will compare both simplification approaches and determine which
approach is optimal. In reality, this could be dependent on the allocator
available on the system, but if there is an obvious choice, the benchmark will
hopefully confirm it.

## Results

### Test 1

Hardware Macbook M1 Pro 32GB
Compiler gcc
10 * 100000 buffers of 1200 bytes
```
➜ build/base64_benchmark max_pad
Generated new seed: '1730238708'
Running test: max_pad
test 0: best: 33.000000; worst: 398.000000; avg: 33.919350; total: 100000
test 1: best: 32.000000; worst: 559.000000; avg: 33.906360; total: 100000
test 2: best: 33.000000; worst: 373.000000; avg: 33.901470; total: 100000
test 3: best: 33.000000; worst: 593.000000; avg: 33.908920; total: 100000
test 4: best: 32.000000; worst: 711.000000; avg: 33.932760; total: 100000
test 5: best: 32.000000; worst: 503.000000; avg: 33.910610; total: 100000
test 6: best: 33.000000; worst: 361.000000; avg: 33.967390; total: 100000
test 7: best: 33.000000; worst: 361.000000; avg: 33.847180; total: 100000
test 8: best: 33.000000; worst: 277.000000; avg: 33.911890; total: 100000
test 9: best: 33.000000; worst: 314.000000; avg: 33.863630; total: 100000
```

```
➜ build/base64_benchmark add_half 1730238708
Using parsed seed: '1730238708'
Running test: add_half
test 0: best: 33.000000; worst: 363.000000; avg: 33.892790; total: 100000
test 1: best: 33.000000; worst: 309.000000; avg: 33.880400; total: 100000
test 2: best: 33.000000; worst: 269.000000; avg: 33.915240; total: 100000
test 3: best: 33.000000; worst: 377.000000; avg: 33.897670; total: 100000
test 4: best: 33.000000; worst: 448.000000; avg: 33.997130; total: 100000
test 5: best: 33.000000; worst: 415.000000; avg: 33.873010; total: 100000
test 6: best: 33.000000; worst: 360.000000; avg: 33.908240; total: 100000
test 7: best: 33.000000; worst: 327.000000; avg: 33.875030; total: 100000
test 8: best: 33.000000; worst: 332.000000; avg: 33.897050; total: 100000
test 9: best: 33.000000; worst: 383.000000; avg: 33.944270; total: 100000
```

```
➜ build/base64_benchmark shift_half 1730238708
Using parsed seed: '1730238708'
Running test: shift_half
test 0: best: 33.000000; worst: 382.000000; avg: 33.874100; total: 100000
test 1: best: 33.000000; worst: 585.000000; avg: 33.916150; total: 100000
test 2: best: 33.000000; worst: 669.000000; avg: 34.018660; total: 100000
test 3: best: 33.000000; worst: 734.000000; avg: 33.963490; total: 100000
test 4: best: 32.000000; worst: 356.000000; avg: 33.902530; total: 100000
test 5: best: 33.000000; worst: 355.000000; avg: 33.891630; total: 100000
test 6: best: 33.000000; worst: 486.000000; avg: 33.867180; total: 100000
test 7: best: 33.000000; worst: 469.000000; avg: 33.936890; total: 100000
test 8: best: 33.000000; worst: 392.000000; avg: 33.919380; total: 100000
test 9: best: 33.000000; worst: 320.000000; avg: 33.879930; total: 100000
```

### Test 2

Hardware Macbook M1 Pro 32GB
Compiler gcc
10 * 100000 buffers of 1650 bytes

```
➜ build/base64_benchmark max_pad              
Generated new seed: '1730239061'
Running test: max_pad
test 0: best: 33.000000; worst: 440.000000; avg: 34.017710; total: 100000
test 1: best: 32.000000; worst: 403.000000; avg: 33.984960; total: 100000
test 2: best: 33.000000; worst: 325.000000; avg: 33.910490; total: 100000
test 3: best: 32.000000; worst: 292.000000; avg: 33.870800; total: 100000
test 4: best: 33.000000; worst: 422.000000; avg: 33.940760; total: 100000
test 5: best: 33.000000; worst: 393.000000; avg: 33.856630; total: 100000
test 6: best: 33.000000; worst: 448.000000; avg: 33.942680; total: 100000
test 7: best: 33.000000; worst: 469.000000; avg: 33.979620; total: 100000
test 8: best: 33.000000; worst: 353.000000; avg: 33.892200; total: 100000
test 9: best: 33.000000; worst: 385.000000; avg: 33.906480; total: 100000
```

```
➜ build/base64_benchmark add_half 1730239061
Using parsed seed: '1730239061'
Running test: add_half
test 0: best: 33.000000; worst: 329.000000; avg: 33.867960; total: 100000
test 1: best: 33.000000; worst: 344.000000; avg: 33.851700; total: 100000
test 2: best: 32.000000; worst: 378.000000; avg: 33.926570; total: 100000
test 3: best: 33.000000; worst: 320.000000; avg: 33.847030; total: 100000
test 4: best: 33.000000; worst: 344.000000; avg: 33.865960; total: 100000
test 5: best: 33.000000; worst: 237.000000; avg: 33.835470; total: 100000
test 6: best: 33.000000; worst: 496.000000; avg: 33.829510; total: 100000
test 7: best: 33.000000; worst: 540.000000; avg: 33.831040; total: 100000
test 8: best: 33.000000; worst: 334.000000; avg: 33.891400; total: 100000
test 9: best: 33.000000; worst: 685.000000; avg: 33.875940; total: 100000
```

```
➜ build/base64_benchmark shift_half 1730239061
Using parsed seed: '1730239061'
Running test: shift_half
test 0: best: 33.000000; worst: 466.000000; avg: 33.818300; total: 100000
test 1: best: 33.000000; worst: 416.000000; avg: 33.911650; total: 100000
test 2: best: 33.000000; worst: 331.000000; avg: 33.861270; total: 100000
test 3: best: 33.000000; worst: 475.000000; avg: 34.127360; total: 100000
test 4: best: 33.000000; worst: 327.000000; avg: 33.853810; total: 100000
test 5: best: 33.000000; worst: 303.000000; avg: 33.874750; total: 100000
test 6: best: 33.000000; worst: 388.000000; avg: 33.839960; total: 100000
test 7: best: 33.000000; worst: 422.000000; avg: 33.863190; total: 100000
test 8: best: 33.000000; worst: 482.000000; avg: 33.902790; total: 100000
test 9: best: 33.000000; worst: 588.000000; avg: 33.841830; total: 100000
```
## Conclusion

No noticeable or significant performance difference between division methods.
We should optimize for memory.

