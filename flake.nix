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

          # Add fm to PATH when entering nix develop, after ensuring it's built
          shellHook = ''
            export PATH=$PATH:${fm-package}/bin
            export PYTHONPATH=${fm-package}/lib/fm:$PYTHONPATH

            # (Optional) Create ~/.config/fm directory if it doesn't exist
            if [ ! -d "$HOME/.config/fm" ]; then
              mkdir -p "$HOME/.config/fm"
            fi

            # (Optional) Copy config.yml to ~/.config/fm if it doesn't exist
            if [ ! -f "$HOME/.config/fm/config.yml" ]; then
              cp ${fm-package}/lib/fm/config.yml "$HOME/.config/fm/config.yml"
            fi
          '';
        };
      }
    );
}
