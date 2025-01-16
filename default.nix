{ lib, pkgs ? import <nixpkgs> {}, fzf, pyyaml }:

pkgs.stdenv.mkDerivation {
  name = "fm";
  src = ./.;
  dontUnpack = true;
  buildInputs = [ fzf pyyaml ]; # Add fzf and pyyaml as build inputs
  installPhase = ''
    mkdir -p $out/bin $out/lib/fm
    cp -r * $out/lib/fm
    ln -s $out/lib/fm/__main__.py $out/bin/fm
    chmod +x $out/bin/fm
  '';

  meta = with lib; {
    description = "FullMetal Function Manager";
    homepage = "https://github.com/your-repo/fm"; # Replace with your repo
    license = licenses.mit;
    maintainers = with maintainers; [ your-nix-username ];
  };
}