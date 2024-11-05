# Dart Crypto Benchmarks

## Setup

### Dependencies

#### Linux / Mac

1. Install `cmake` & `clang` through your package manager

> A more recent version of cmake is required (3.24) you can install latest
> through python if your distro's version isn't new enough.

#### Windows

1. Install [chocolatey](https://chocolatey.org)

2. Install these packages:
```
choco install cmake
choco install clang
choco install llvm
choco install nasm
```

### Build crypto libraries

#### Webcrypto (Boring SSL)

```
dart pub get
dart run webcrypto:setup
```

#### Build Mbedtls Bindings (atsdk atchops in C99)

Create the dynamic library (from this directory):
```
cmake -B build -S .
cmake --build build
```

Generate the ffi bindings (from the repository root):
```
dart pub get
melos update
melos ffi
```

### Compile the benchmark

```
dart compile exe bin/benchmark.dart
```

## Running the benchmark

You must run from the project root (not repo root):

Generate and run with `N` bytes:
```
bin/benchmark N
```

Run with a random string:

```
bin/benchmark "Hello world"
```

