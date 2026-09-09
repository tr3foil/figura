{ config, ... }: let
  cfg = config.services.calibre-server;
  cfgTa = config.services.tinyauth;
in {

services = {
  calibre-server = {
    enable = true;
    host = "localhost";
    port = 8391;
    openFirewall = false;
    libraries = [
      "/srv/calibre/library"
      "/srv/calibre/alt"
    ];
    auth = {
      enable = true;
      userDb = "/srv/calibre/users.sqlite";
      mode = "basic";
    };
  };

  caddy.virtualHosts."books.clover.isons.org".extraConfig = ''
    forward_auth ${cfgTa.settings.SERVER_ADDRESS}:${toString cfgTa.settings.SERVER_PORT} {
      uri /api/auth/caddy
    }

    reverse_proxy ${cfg.host}:${toString cfg.port}

    # for uploading big books
    request_body {
      max_size 1G
    }
  '';

  tinyauth.settings = {
    APPS_CALIBRE_CONFIG_DOMAIN = "books.clover.isons.org";
    APPS_CALIBRE_OAUTH_GROUPS = "readers";
  };
};

}
