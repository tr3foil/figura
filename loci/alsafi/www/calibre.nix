{ config, ... }: let
  cfg = config.services.calibre-server;
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
    reverse_proxy ${cfg.host}:${toString cfg.port}

    # for uploading big books
    request_body {
      max_size 1G
    }
  '';
};

}
