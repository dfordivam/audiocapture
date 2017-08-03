{ nixpkgs ? import <nixpkgs> {}
, reflex-platform ? import ~/repos/reflex/reflex-platform {}
, ghc ? reflex-platform.ghcjs }:

let

  inherit (nixpkgs) pkgs;

  drv = ghc.callPackage
      (ghc.haskellSrc2nix {
        src = ./.;
          name = "audiocapture"; })
          { };
in

  if pkgs.lib.inNixShell then drv.env else drv
