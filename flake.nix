{
  description = "Intel HPC Kit";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    shell-utils.url = "github:waltermoreira/shell-utils";
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    , shell-utils
    }:

      with flake-utils.lib; eachSystem [
        system.x86_64-linux
      ]
        (system:
        let
          pkgs = import nixpkgs { inherit system; };
          shell = shell-utils.myShell.${system};
          debPackages = [
            {
              package = "intel-basekit-2023.2.0-49384_amd64";
              hash = "sha256-ZlRDUwMN9Y7EKVbKzzWRNbGFHZrC/lps34pX/Ylqsrw=";
            }
            {
              package = "intel-hpckit-getting-started-2023.2.0-49438_all";
              hash = "sha256-yZPGFSa/+ki1cHGN2HHRWFoGz9rsFIC5rxFe1Hg9oQs=";
            }
            {
              package = "intel-oneapi-common-vars-2023.2.0-49462_all";
              hash = "sha256-52MaO9uaJTmuoSRf18Nlf/MdRxFVNL1rDofcYqlVOwU=";
            }
            {
              package = "intel-oneapi-common-licensing-2023.2.0-49462_all";
              hash = "sha256-vXQlCuywY2Iu41FYnr3y71Y4Cc2nP5R7BFEbG8DxBI4=";
            }
            {
              package = "intel-oneapi-dev-utilities-2021.10.0-49423_amd64";
              hash = "sha256-G4qRURUy2+rJpURoIZZIQtvURiUQCvoRVBdxsbC/zFc=";
            }
            {
              package = "intel-oneapi-inspector-2023.2.0-49301_amd64";
              hash = "sha256-yBEsKouU0REI1Hj1jCRQMoBJOjU3okuM+wp554NIfsA=";
            }
            {
              package = "intel-oneapi-itac-2021.10.0-11_amd64";
              hash = "sha256-oV8QmFnuvRJra42Mjh8qlcDGu+aOnrYzsB8Rg2Nsmh4=";
            }
            {
              package = "intel-oneapi-diagnostics-utility-2022.4.0-49091_amd64";
              hash = "sha256-dCSzP3WikHdTO5qIUJxc63pK9E1dMdmpxB+UqmstKFM=";
            }
            {
              package = "intel-oneapi-mpi-2021.10.0-2021.10.0-49371_amd64";
              hash = "sha256-sFl6rV+2uK/G6SpX4y+gE8NGmvd2jel5YTmdQTz4FAU=";
            }
            {
              package = "intel-oneapi-mpi-devel-2021.10.0-2021.10.0-49371_amd64";
              hash = "sha256-mPjRQ+pHDCIRjWaDHNUjEcLFtMUsZwunC/dzNhx/BvE=";
            }
            {
              package = "intel-oneapi-compiler-dpcpp-cpp-and-cpp-classic-2023.2.1-16_amd64";
              hash = "sha256-f5sO/KTCQKCp0ML5CjxilGJ7cO+xTnu6ofvmpZuQUMc=";
            }
            {
              package = "intel-oneapi-compiler-fortran-2023.2.1-16_amd64";
              hash = "sha256-LGY5eTVvblzzc4eF/fwsHYbJXUyUO3aaBh6wscrGTh8=";
            }
            {
              package = "intel-oneapi-compiler-shared-runtime-2023.2.1-2023.2.1-16_amd64";
              hash = "sha256-8WgKCM6FKNVBNDLYpucmYeFOjLHbR42Pie83g3FOCV0=";
            }
            {
              package = "intel-oneapi-compiler-dpcpp-cpp-runtime-2023.2.0-2023.2.0-49495_amd64";
              hash = "sha256-9j1HQA+F/rbB+wat4DkLriSBow3BDo4LRF0Y2nzs/PA=";
            }
          ];
          hpcKitDebs = map
            ({ package, hash }: pkgs.fetchurl {
              url = "https://apt.repos.intel.com/oneapi/pool/main/${package}.deb";
              inherit hash;
            })
            debPackages;
          hpcKit = pkgs.stdenv.mkDerivation {
            name = "hpcKit";
            source = self;
            dontUnpack = true;
            dontBuild = true;
            nativeBuildInputs = with pkgs; [
              autoPatchelfHook
            ];
            buildInputs = with pkgs; [
              zlib
              pango
              cairo
              fontconfig
              freetype
              gtk2
              sqlite
              xorg.libXxf86vm
              level-zero
              rdma-core
              numactl
              ucx
              libpsm2
              libffi_3_3
              tbb_2021_8
              gcc
            ];
            installPhase = with pkgs; ''
              mkdir -p $out
              for deb in ${builtins.toString hpcKitDebs}; do
                echo "Extracting: $deb"
                # mkdir -p $out/$deb
                ${dpkg}/bin/dpkg-deb -x $deb $out
              done
              ln -s $out/opt/intel/oneapi/mpi/2021.10.0/bin $out/bin
              ln -s $out/opt/intel/oneapi/mpi/2021.10.0/env $out/env
              ln -s $out/opt/intel/oneapi/mpi/2021.10.0/lib $out/lib

              # workaround to use gfortran with intel mpi
              ln -sf \
                $out/opt/intel/oneapi/mpi/2021.10.0/include/gfortran/10.2.0/mpi.mod \
                $out/opt/intel/oneapi/mpi/2021.10.0/include/mpi.mod
            '';
          };
        in
        {
          devShells.default = shell {
            name = "Intel-HPC-Kit";
            packages = [ hpcKit ];
            shellHook = ''
              source ${hpcKit}/env/vars.sh
            '';
          };
          packages.default = hpcKit;

          packages.dockerImage = pkgs.dockerTools.buildLayeredImage {
            name = "intel-hpc-kit";
            tag = "latest";
            fromImage = pkgs.dockerTools.pullImage {
              imageName = "wangyinz/nix_test_impi";
              imageDigest = "sha256:4d4f3ae7755700152b1e2982d5208b5eaf385176a4f956fc531db587dd788b8a";
              sha256 = "sha256-bsdmcglYypqw1HaA3Vg1d4HZvXa+V0WOgqOhLj+n9YI=";
              os = "linux";
              arch = "x86_64";
            };
            contents = pkgs.buildEnv {
              name = "image-root";
              paths = [ hpcKit ];
              extraPrefix = "/tacc";
            };
            config = {
              Cmd = [ "${pkgs.bash}/bin/bash" ];
            };
          };

        });
}
