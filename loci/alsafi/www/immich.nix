{ config, ... }: let
  cfg = config.services.immich;
in {

services = {
  immich = {
    enable = true;
    host = "localhost";
    openFirewall = false;
  };

  caddy.virtualHosts."pics.clover.isons.org".extraConfig = ''
    reverse_proxy ${cfg.host}:${toString cfg.port}
  '';
};

}
