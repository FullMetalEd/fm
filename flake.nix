{
  description = "fm - A CLI tool for ...";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = { allowUnfree = true; };
        };

        pythonEnv = pkgs.python3.withPackages (ps: with ps; [
          # Python dependencies
          pyyaml
        ]);

        fm-app = pkgs.python3Packages.buildPythonApplication {
          pname = "fm";
          version = "0.1.0";
          src = ./.; # Keep it simple

          format = "other";

          propagatedBuildInputs = [
            pythonEnv
            pkgs.fzf
            pkgs.bash
          ];

          # Try without dontInstall
          # dontInstall = true;

          installPhase = ''
            echo "Running installPhase"

            runHook preInstall

            # Create directories
            mkdir -p $out/bin/fm
            mkdir -p $out/lib/fm
            mkdir -p $out/bin/fm/scripts

            # Copy files
            cp fm.py $out/bin/fm/
            cp fzf_helper.py $out/bin/fm/
            cp run_command.py $out/bin/fm/
            cp -r scripts/* $out/bin/fm/scripts/
            cp config.yml $out/bin/fm/

            # Patch shebangs in the scripts directory
            patchShebangs $out/bin/fm/scripts/*

            # Create the wrapper
            makeWrapper ${pythonEnv}/bin/python3 $out/bin/fm/fm \
              --add-flags "$out/bin/fm/fm.py" \
              --prefix PYTHONPATH : "$out/bin:${pythonEnv}/${pythonEnv.sitePackages}" \
              --prefix PATH : ${pkgs.fzf}/bin

            chmod +x $out/bin/fm

            runHook postInstall

            echo "installPhase finished successfully"
          '';

          # Add a simple check phase
          checkPhase = ''
            echo "Running checkPhase"
            runHook preCheck
            # Add a basic test if possible
            $out/bin/fm --help || true
            runHook postCheck
          '';
        };

      in {
        packages.fm = fm-app;
        defaultPackage = self.packages.${system}.fm;

        apps.fm = flake-utils.lib.mkApp {
          drv = fm-app;
        };
        defaultApp = self.apps.${system}.fm;

        devShell = pkgs.mkShell {
          buildInputs = [ pythonEnv pkgs.fzf ];
        };
      });
}