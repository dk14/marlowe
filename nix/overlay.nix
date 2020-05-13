self: super:
let
  pkgs = super;
  pkgsForOldZ3 = import (builtins.fetchGit {
    name = "nixos-old-z32";
    url = "https://github.com/nixos/nixpkgs-channels/";
    ref = "refs/heads/nixos-unstable";
    rev = "194168b7225b341399ccd8948faf2075896033ca";
  }) {};
  polymlNewAndPatched = pkgs.polyml.overrideAttrs(args: pkgs.recurseIntoAttrs(rec {
    version = "5.8"; 
    configureFlags = args.configureFlags ++ ["--enable-intinf-as-int"];
    src = pkgs.fetchFromGitHub {
      owner = "polyml";
      repo = "polyml";
      rev = "v${version}";
      sha256 = "1s7q77bivppxa4vd7gxjj5dbh66qnirfxnkzh1ql69rfx1c057n3";
    };
  }));
  isabelle2018 = pkgs.isabelle.override(args: {z3 = pkgsForOldZ3.z3; polyml = polymlNewAndPatched; });
  isabelle2019 = isabelle2018.overrideAttrs(args: pkgs.recurseIntoAttrs(rec {
    version = "2019"; 
    dirname = "Isabelle${version}";
    src = if pkgs.stdenv.isDarwin
      then pkgs.fetchurl {
        url = "http://isabelle.in.tum.de/website-${dirname}/dist/${dirname}.dmg";
        sha256 = "6772d28fae247d4ed062d6c56beb5225b3db2cf24070bbcad69b4de90f87f1fb";
      }
      else pkgs.fetchurl {
        url = "https://isabelle.in.tum.de/website-${dirname}/dist/${dirname}_linux.tar.gz";
        sha256 = "15hr8n821nhwghi244ll42zbihf7qc3flfb7wkk3yd7121220srg";
      };
  }));
in {
  z3 = pkgsForOldZ3;
  polyml = polymlNewAndPatched;
  isabelle = isabelle2019;
}