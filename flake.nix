{
  description = "opens a shell with mpasmx and related tools";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
  };
  outputs = {nixpkgs, ...}: let
    system = "x86_64-linux";

    pkgs = import nixpkgs {
      inherit system;
      config = {allowUnfree = true;};
    };
    mpasmx-unwrapped = pkgs.stdenv.mkDerivation {
      pname = "mpasmx-unwrapped";
      version = "1";
      src = pkgs.fetchFromGitHub {
        owner = "colonelkrab";
        repo = "mpasmx-copy";
        rev = "d6016b4f7d3b7b3c1e7e3d85232c16f69f6defaa";
        sha256 = "sha256-/jj/+igkVMgpZQdAlq7SXJU5jr4G6Vunu60mw9IqL+4=";
      };
      unpackPhase = ''
        runHook preUnpack
        tar xf $src/mpasmx.tar.gz
        runHook postUnpack

      '';
      installPhase = ''
        runHook preInstall
        cp -r ./mpasmx/ $out/
        runHook postInstall
      '';
    };
    mpasmx-fhs = pkgs.buildFHSEnv {
      multiArch = true;
      name = "mpasmx-fhs";
      targetPkgs = pkgs: [
        pkgs.pk2cmd
      ];
      profile = ''
        export PATH="$PATH:/${mpasmx-unwrapped}/"
      '';
    };
  in {
    devShells.${system}.default = mpasmx-fhs.env;
  };
}
