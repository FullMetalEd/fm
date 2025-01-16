{
  description = "A flake for the FullMetal Function Manager (fm)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        fm-package = pkgs.callPackage ./default.nix { inherit (pkgs) lib; };
      in
      {
        packages = rec {
          fm = fm-package;
          default = fm;
        };

        devShells.default = pkgs.mkShell {
          buildInputs = [
            pkgs.python3
            pkgs.python3Packages.pyyaml
            pkgs.fzf
            fm-package # Ensure fm is built and available in the develop environment
          ];
          packages = [ self.packages.${system}.fm ];
        };
      }
    );
}