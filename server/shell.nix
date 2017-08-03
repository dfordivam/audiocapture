{ nixpkgs ? import <nixpkgs> {}
, reflex-platform ? import ~/repos/reflex/reflex-platform {}
, ghc ? reflex-platform.ghc }:

let

  inherit (nixpkgs) pkgs;

  reflex-websocket-interface-shared = ghc.callPackage ~/repos/reflex/reflex-websocket-interface/shared {};
  reflex-websocket-interface-server = ghc.callPackage ~/repos/reflex/reflex-websocket-interface/server {inherit reflex-websocket-interface-shared;};

#  shared = ghc.callPackage
#      (ghc.haskellSrc2nix {
#        src = ../shared;
#          name = "shared"; })
#          { inherit reflex-websocket-interface-shared;};

  drv = ghc.callPackage
      (ghc.haskellSrc2nix {
        src = ./.;
          name = "server"; })
          {
#    inherit reflex-websocket-interface-shared reflex-websocket-interface-server shared;
    };

in

  if pkgs.lib.inNixShell then drv.env else drv
