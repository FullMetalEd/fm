{ lib, pkgs ? import <nixpkgs> {}, fzf, pyyaml }:

pkgs.stdenv.mkDerivation {
  name = "fm";
  src = ./.;
  dontUnpack = true;
  buildInputs = [ fzf pyyaml ]; # Add fzf and pyyaml as build inputs
  installPhase = ''
    mkdir -p $out/bin $out/etc/fm
    cp -r ./* $out/etc/fm
    #ln -s $out/etc/fm/fm.py $out/bin/fm
    touch $out/bin/fm
    chmod +x $out/bin/fm
  '';

  meta = with lib; {
    description = "FullMetal Function Manager";
    homepage = "https://github.com/your-repo/fm"; # Replace with your repo
    license = licenses.mit;
    maintainers = with maintainers; [ your-nix-username ];
  };
}