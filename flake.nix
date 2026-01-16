{
  description = "traO Judge language environment";

  inputs = {
    # nixpkgs 25.11
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

    # flake-parts
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs @ {flake-parts, ...}: let
    traoLib = import ./lib;
  in
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        traoLib.flakeModule
        ./lang
      ];
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];

      perSystem = {pkgs, ...}: {
        formatter = pkgs.alejandra;
      };
    };
}
