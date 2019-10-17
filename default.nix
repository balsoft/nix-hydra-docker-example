let sources = import ./nix/sources.nix;
in 
{ pkgs ? import sources.nixpkgs nixpkgsArgs
, supportedSystems ? [ "x86_64-linux" ]
, nixpkgsArgs ? { config.inHydra = true; }
, releaseLib ?
  import "${sources.nixpkgs}/pkgs/top-level/release-lib.nix" {
    inherit nixpkgsArgs supportedSystems;
  } }:
pkgs.lib.genAttrs supportedSystems
(system: { mc = (releaseLib.pkgsFor system).mc; })

