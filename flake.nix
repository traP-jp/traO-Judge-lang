{
  description = "traO Judge language environment";

  inputs = {
    # nixpkgs 25.05
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";

    # flake-parts
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [];
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];

      perSystem = {pkgs, ...}: {
        packages = let
          cpp23-gpp15 = import ./lang/cpp23-gpp15 {inherit pkgs;};
        in {
          cpp23-gpp15 = cpp23-gpp15;
        };

        formatter = pkgs.alejandra;
      };
    };
}
