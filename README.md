# Intel oneAPI MPI Library

This is a flake to use Intel [oneAPI MPI Library](https://www.intel.com/content/www/us/en/developer/tools/oneapi/mpi-library.html).

## Requirements

A working installation of Nix on Linux x86_64

## Usage

1. Clone this repository and run:
   ```bash
   cd intel-mpi-nix
   nix develop
   ```
2. Compile the provided Hello World example with:
   ```bash
   mpicc -o hello hello.c
   ```
3. Run the example with:
   ```bash
   mpirun ./hello
   ```

Alternatively, you can run the development environment directly from Github with:
```bash
nix develop github:waltermoreira/intel-mpi-nix
```
and use the environment to compile your own sources.

## To Do

- Support ARM architecture.

## License 

MIT
