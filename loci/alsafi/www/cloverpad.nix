{ config, pkgs, inputs, ... }: let
  inherit (config.www) domain;
in {

services.caddy.virtualHosts.${domain} = {
  extraConfig = let
    cloverpad = inputs.cloverpad.packages.${pkgs.stdenv.hostPlatform.system}.default;
  in ''
    root ${cloverpad}/site
    file_server
  '';
};

}
