{ nixpkgs ? import <nixpkgs> {}
, reflex-platform ? import ~/repos/reflex/reflex-platform {}
, ghc ? reflex-platform.ghc }:

let

  inherit (nixpkgs) pkgs;

  drv = ghc.callPackage
      (ghc.haskellSrc2nix {
        src = ./.;
          name = "server"; })
          { };

in

  if pkgs.lib.inNixShell then drv.env else drv
