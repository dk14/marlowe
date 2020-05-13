let
  sources = import ./nix/sources.nix;
  isabelleOverlay = import ./nix/overlays/isabelle.nix;
  pkgs = import sources.nixpkgs {
    overlays = [
      (_ : _ : { niv = import sources.niv {}; })
      isabelleOverlay
    ] ;
    config = {};
  };
  isabelleBuild = ''
      export HOME=$TMP
      export PATH=$PATH:${pkgs.stdenv.lib.makeBinPath [pkgs.perl pkgs.isabelle]}
      cd isabelle
      isabelle build -d. Test
    '';
in rec {
  isabelleTest = pkgs.stdenv.mkDerivation {  
      name = "isabelle-test";
      src = ./.;
      configurePhase = "true"; 	# Skip configure
      buildInputs = [pkgs.z3 pkgs.polyml pkgs.isabelle];
      buildPhase = isabelleBuild;
      installPhase = "true"; # don't want to install
  };
}

