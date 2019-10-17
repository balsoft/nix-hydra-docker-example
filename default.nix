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
(system: rec { 
  mc = (releaseLib.pkgsFor system).mc; 
  docker.mc = pkgs.dockerTools.buildImage {
    name = "mc";
    contents = with pkgs; [stdenv coreutils bash mc];
    config = { Cmd = [ "/bin/bash" ]; };
  };
  activator = pkgs.writeScriptBin "activate" ''
    cat /etc/docker_password | ${pkgs.docker}/bin/docker login -u balsoft --password-stdin
    ${pkgs.docker}/bin/docker import ${docker.mc} hub.docker.com/balsoft/nix-hydra-docker-example:${mc.version}
    ${pkgs.docker}/bin/docker push hub.docker.com/balsoft/nix-hydra-docker-example
  '';
})

