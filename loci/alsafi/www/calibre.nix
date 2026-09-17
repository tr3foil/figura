{ config, ... }: let
  cfg = config.services.calibre-server;
  cfgTa = config.services.tinyauth;
  domain = "books.${config.www.domain}";
in {

sops.secrets."calibre-clover.password" = {
  sopsFile = ../secrets.yaml;
  owner = cfgTa.user;
  restartUnits = [ "tinyauth.service" ];
};

services = {
  calibre-server = {
    enable = config.www.enable;
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

  # TODO: deduplicate
  caddy.virtualHosts = {
    ${domain}.extraConfig = ''
      forward_auth ${cfgTa.settings.SERVER_ADDRESS}:${toString cfgTa.settings.SERVER_PORT} {
        uri /api/auth/caddy
      }

      reverse_proxy ${cfg.host}:${toString cfg.port}

      # for uploading big books
      request_body {
        max_size 1G
      }
    '';
    "c-${domain}".extraConfig = ''
      forward_auth ${cfgTa.settings.SERVER_ADDRESS}:${toString cfgTa.settings.SERVER_PORT} {
        uri /api/auth/caddy
        copy_headers Authorization
      }

      reverse_proxy ${cfg.host}:${toString cfg.port}

      # for uploading big books
      request_body {
        max_size 1G
      }
    '';
  };

  tinyauth.settings = {
    APPS_CALIBRE_CONFIG_DOMAIN = domain;
    APPS_CALIBRE_OAUTH_GROUPS = "readers";
    # subdomain with autologin just for me :3
    APPS_MYCALIBRE_CONFIG_DOMAIN = "c-${domain}";
    APPS_MYCALIBRE_OAUTH_WHITELIST = "clover@isons.org";
    APPS_MYCALIBRE_RESPONSE_BASICAUTH_USERNAME = "clover";
    APPS_MYCALIBRE_RESPONSE_BASICAUTH_PASSWORDFILE = config.sops.secrets."calibre-clover.password".path;
    # workaround pwa breaking because of cors stuff idk
    APPS_CALIBRE_PATH_ALLOW = "/manifest.json";
    APPS_MYCALIBRE_PATH_ALLOW = "/manifest.json";
  };
};

}
