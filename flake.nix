{
  description = "My Devshells";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { nixpkgs, ... }:
    let
      forAllSystems =
        f:
        nixpkgs.lib.genAttrs [
          "x86_64-linux"
          "aarch64-linux"
        ] (system: f nixpkgs.legacyPackages.${system});
    in
    {
      devShells = forAllSystems (pkgs: {
        comfyui =
          let
            nixLibPath = pkgs.lib.makeLibraryPath [
              pkgs.stdenv.cc.cc.lib
              pkgs.zlib
              pkgs.libglvnd
              pkgs.glib
              pkgs.iconv
              pkgs.libxcb
            ];
            runtimeLibPath = "${nixLibPath}:/run/opengl-driver/lib:/run/opengl-driver-32/lib";
          in
          pkgs.mkShell {
            packages = [
              pkgs.python313
              pkgs.uv
              pkgs.python313Packages.huggingface-hub
              pkgs.ffmpeg
              pkgs.git-lfs
              pkgs.ruff
            ];

            shellHook = ''
              export LD_LIBRARY_PATH="${runtimeLibPath}:''${LD_LIBRARY_PATH:-}"
              export TRITON_LIBCUDA_PATH=/run/opengl-driver/lib
            '';
          };
      });
    };
}
