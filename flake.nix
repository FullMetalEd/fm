{
  description = "A flake for the FullMetal Function Manager (fm)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux; 
      fm-package = pkgs.callPackage ./default.nix { 
          inherit (pkgs) lib; 
          fzf = pkgs.fzf;
          pyyaml = pkgs.python3Packages.pyyaml;
      };
    in
    {
      packages.x86_64-linux = { 
        default = fm-package;
      };
      devShells.x86_64-linux = {
        default = pkgs.mkShell {
          buildInputs = [
            pkgs.python3
            pkgs.python3Packages.pyyaml
            pkgs.fzf
            fm-package
          ];
          packages = [ fm-package ];
        };
      };
    };
}