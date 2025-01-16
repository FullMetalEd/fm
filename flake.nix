{
  description = "A flake for the FullMetal Function Manager (fm)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs@{ self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        fm-package = pkgs.callPackage ./default.nix {
          inherit (pkgs) lib;
          fzf = pkgs.fzf;
          pyyaml = pkgs.python3Packages.pyyaml;
        };
      in rec {
        devShells.default = pkgs.mkShell {
          buildInputs = [ pkgs.python3 pkgs.python3Packages.pyyaml pkgs.fzf fm-package];
        };

        packages = fm-package; 
      }
    );
}
