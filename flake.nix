{
  description = "fm - Function/File Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    # Remove flake-utils/systems
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages = rec {
          fm = pkgs.callPackage ./default.nix {
            inherit (pkgs) lib;
            python3Packages = pkgs.python3Packages;
            fzf = pkgs.fzf;
          };
          default = fm;
        };

        devShells.default = pkgs.mkShell {
          packages = [ self.packages.${system}.fm ];
        };
      }
    );
}