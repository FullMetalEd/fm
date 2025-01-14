{ stdenv, python3Packages, fzf }:

stdenv.mkDerivation rec {
  pname = "fm";
  version = "0.1.0"; # Update as needed

  src = ./.; # Source is the current directory (flake root)

  buildInputs = [ python3Packages.python fzf ];

  installPhase = ''
    mkdir -p $out/bin $out/share/fm/scripts
    install -m 755 fm.py $out/bin/fm

    # Install scripts
    install -m 755 scripts/* $out/share/fm/scripts/

    # Create a wrapper to set FM_SCRIPTS_DIR
    cat > $out/bin/fm-wrapper <<EOF
    #!${stdenv.shell}
    export FM_SCRIPTS_DIR=\$out/share/fm/scripts
    exec \$out/bin/fm "\$@"
    EOF
    chmod +x $out/bin/fm-wrapper

    # Make fm-wrapper the default command
    ln -s $out/bin/fm-wrapper $out/bin/fm
  '';

  meta = with stdenv.lib; {
    description = "A terminal application for managing custom scripts";
    homepage = "https://github.com/yourusername/fm"; # Your repo URL
    license = licenses.mit; # Choose an appropriate license
    maintainers = [ maintainers.yourusername ]; # Your NixOS username
    platforms = platforms.linux;
  };
}