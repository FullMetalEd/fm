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
        fm-package = pkgs.callPackage ./default.nix {
          inherit (pkgs) lib;
          fzf = pkgs.fzf;
          pyyaml = pkgs.python3Packages.pyyaml;
        };
      in
      {
    devShells.x86_64-linux.default = pkgs.mkShell {
      inputsFrom = [ build ];
      buildInputs = with pkgs; [ python3 python3Packages.pyyaml fzf ];
    };

    packages.x86_64-linux.default = build; 
  };
}