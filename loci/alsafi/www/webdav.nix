{ config, ... }: let
  cfg = config.services.webdav;
in {

services = {
  webdav = {
    enable = true;
    environmentFile = config.sops.secrets."webdav.env".path;
    settings = {
      address = "localhost";
      port = 8689;
      directory = "/srv/webdav/seedvault";
      permissions = "none";
      users = [ {
        username = "{env}USERNAME";
        password = "{env}PASSWORD";
        permissions = "CRUD";
      } ];
    };
  };

  caddy.virtualHosts."webdav.clover.isons.org".extraConfig = ''
    reverse_proxy ${cfg.settings.address}:${toString cfg.settings.port}
  '';
};

sops.secrets."webdav.env".sopsFile = ../secrets.yaml;

}
