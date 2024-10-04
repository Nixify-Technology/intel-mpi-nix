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

### Composing with other flakes

Code that compiles using other MPI implementations (for example, `nixpkgs.mpich`) can
use this flake as a drop-in replacement.

1. Add the input `intel-mpi.url = "github:Nixify-Technology/intel-mpi-nix"` to your flake.
2. Instantiate the default package with:
   ```
   mpi = intel-mpi.packages.${system}.default;
   ```
3. Use the package `mpi` as a replacement for `mpich` or any other implementation.

## To Do

- Support ARM architecture.

## License 

MIT
