{ config, ... }: let
  cfg = config.services.calibre-server;
in {

services = {
  calibre-server = {
    enable = true;
    host = "::1";
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

  nginx = {
    clientMaxBodySize = "1G"; # for uploading big books
    virtualHosts."calibre.clover.isons.org" = {
      forceSSL = true;
      useACMEHost = "clover.isons.org";
      locations."/" = {
        proxyPass = "http://[::1]:" + toString cfg.port;
        recommendedProxySettings = true;
      };
    };
  };
};

}
