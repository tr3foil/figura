{ config, ... }: let
  cfg = config.services.webdav;
  domain = "webdav.${config.www.domain}";
in {

services = {
  webdav = {
    enable = config.www.enable;
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

  caddy.virtualHosts.${domain}.extraConfig = ''
    tls {
      client_auth {
        trust_pool file ${config.sops.secrets."caddy-mtls_client-ca.crt".path}
      }
    }
    reverse_proxy ${cfg.settings.address}:${toString cfg.settings.port}
  '';
};

sops.secrets."webdav.env".sopsFile = ../secrets.yaml;

}
