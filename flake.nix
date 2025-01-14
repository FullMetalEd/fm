{
  description = "fm - Function/File Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages = rec {
          fm = pkgs.callPackage ./default.nix {
            python3Packages = pkgs.python3Packages;
            fzf = pkgs.fzf; # Pass fzf to the derivation
          };
          default = fm;
        };

        devShells.default = pkgs.mkShell {
          packages = [ self.packages.${system}.fm ];
        };
      }
    );
}