let
  pkgs = import <nixpkgs> { };
  isabelleBuild = ''
      export HOME=$TMP
      export PATH=$PATH:${pkgs.stdenv.lib.makeBinPath [pkgs.perl pkgs.isabelle]}
      cd isabelle
      isabelle build -d. Test
    '';
in rec {
  isabelleTest = pkgs.stdenv.mkDerivation {  
      name = "lemenv";
      src = ./.;
      configurePhase = "true"; 	# Skip configure
      buildPhase = isabelleBuild;
      installPhase = "true"; # don't want to install
  };
}

