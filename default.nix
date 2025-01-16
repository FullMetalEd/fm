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

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/lib/fm

    # Copy the necessary files individually
    if [ -d ${src}/scripts ]; then
      cp -r ${src}/scripts/ $out/lib/fm/
    fi
    install -m 755 config.yml $out/lib/fm
    install -m 755 __main__.py $out/lib/fm
    install -m 755 cli.py $out/lib/fm
    install -m 755 fzf_helper.py $out/lib/fm
    install -m 755 run_command.py $out/lib/fm

    # Create a wrapper to set FM_SCRIPTS_DIR
    cat > $out/bin/fm-wrapper <<EOF
    #!${stdenv.shell}
    export FM_SCRIPTS_DIR=\$out/lib/fm/scripts
    export FM_CONFIG_PATH="\$out/lib/fm/config.yml"
    exec ${python3}/bin/python3 "/lib/fm/__main__.py" "\$@"
    EOF
    chmod +x $out/bin/fm-wrapper

    # Make fm-wrapper the default command
    ln -s $out/bin/fm-wrapper $out/bin/fm
    
    # Create symlinks for scripts in $out/bin
    if [ -d $out/lib/fm/scripts ]; then
      for script in $(find $out/lib/fm/scripts -type f -executable); do
        ln -s "$script" "$out/bin/$(basename "$script")"
      done
    fi
  '';

  meta = with lib; {
    description = "FullMetal Function Manager";
    homepage = "https://github.com/your-repo/fm"; # Replace with your repo
    license = licenses.mit;
    maintainers = with maintainers; [ your-nix-username ];
  };
}