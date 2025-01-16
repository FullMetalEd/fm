{ stdenv, python3, python3Packages, fzf, makeWrapper, lib, patchelf }:

stdenv.mkDerivation rec {
  pname = "fm";
  version = "0.1.0";

  src = ./.;

  buildInputs = [
    python3
    python3Packages.pyyaml
    fzf
  ];

  nativeBuildInputs = [
    makeWrapper
    patchelf
  ];

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/lib/fm

    # Copy the necessary files individually
    if [ -d ${src}/scripts ]; then
      cp -r ${src}/scripts $out/lib/fm/
    fi
    cp ${src}/config.yml $out/lib/fm/
    cp ${src}/fm/__main__.py $out/lib/fm/fm/
    cp ${src}/fm/cli.py $out/lib/fm/fm/
    cp ${src}/fm/fzf_helper.py $out/lib/fm/fm/
    cp ${src}/fm/run_command.py $out/lib/fm/fm/

    # Create a wrapper script for 'fm'
    makeWrapper ${python3}/bin/python3 $out/bin/fm \
      --add-flags "$out/lib/fm/fm/__main__.py" \
      --set PYTHONPATH "$out/lib/fm:$PYTHONPATH"

    # Create symlinks for scripts in $out/bin
    if [ -d $out/lib/fm/scripts ]; then
      for script in $(find $out/lib/fm/scripts -type f -executable); do
        ln -s "$script" "$out/bin/$(basename "$script")"
      done
    fi
  '';

  postInstall = ''
    # Update shebangs in scripts and main files
    for file in $(find $out -type f); do
      if [[ "$file" == *.sh ]]; then
        sed -i '1s|^#!.*$|#!/usr/bin/env bash|' "$file"
      elif [[ "$file" == *.py ]]; then
        sed -i '1s|^#!.*$|#!/usr/bin/env python3|' "$file"
      fi
    done
  '';

  meta = with lib; {
    description = "FullMetal Function Manager";
    homepage = "https://github.com/your-repo/fm"; # Replace with your repo
    license = licenses.mit;
    maintainers = with maintainers; [ your-nix-username ];
  };
}