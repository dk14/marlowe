self: super:
let
  pkgs = super;
  #pkgsForOldZ3 = import (builtins.fetchGit {
  #  name = "nixos-old-z32";
  #  url = "https://github.com/nixos/nixpkgs-channels/";
  #  ref = "refs/heads/nixos-unstable";
  #  rev = "194168b7225b341399ccd8948faf2075896033ca";
  #}) {};
  z3old = pkgs.stdenv.mkDerivation rec {
    name = "z3-${version}";
    version = "4.4.1";

    src = pkgs.fetchFromGitHub {
      owner  = "Z3Prover";
      repo   = "z3";
      rev    = "z3-${version}";
      sha256 = "1ix100r1h00iph1bk5qx5963gpqaxmmx42r2vb5zglynchjif07c";
    };

    buildInputs = [ pkgs.python ];
    enableParallelBuilding = true;

    configurePhase = "python scripts/mk_make.py --prefix=$out && cd build";
    soext = if pkgs.stdenv.system == "x86_64-darwin" then ".dylib" else ".so";
    installPhase = ''
      mkdir -p $out/bin $out/lib/${pkgs.python.libPrefix}/site-packages $out/include
      cp ../src/api/z3*.h       $out/include
      cp ../src/api/c++/z3*.h   $out/include
      cp z3                     $out/bin
      cp libz3${soext}          $out/lib
      cp libz3${soext}          $out/lib/${pkgs.python.libPrefix}/site-packages
      cp z3*.pyc                $out/lib/${pkgs.python.libPrefix}/site-packages
      cp ../src/api/python/*.py $out/lib/${pkgs.python.libPrefix}/site-packages
    '';

    meta = {
      description = "A high-performance theorem prover and SMT solver";
      homepage    = "http://github.com/Z3Prover/z3";
      license     = pkgs.stdenv.lib.licenses.mit;
      platforms   = pkgs.stdenv.lib.platforms.unix;
      maintainers = [ pkgs.stdenv.lib.maintainers.thoughtpolice ];
    };
  };

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

  isabelle2018 = pkgs.isabelle.override(args: {z3 = z3old; polyml = polymlNewAndPatched; });

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
  z3 = z3old;
  polyml = polymlNewAndPatched;
  isabelle = isabelle2019;
}