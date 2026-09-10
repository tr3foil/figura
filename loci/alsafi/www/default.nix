{ config, ... }: {

imports = [
  ./webdav.nix
  ./calibre.nix
  ./peertube.nix
  ./immich.nix
  ./cloverpad.nix
  ./auth
];

sops.secrets = {
  "duckdns.token".sopsFile = ../secrets.yaml;
  "caddy-mtls_client-ca.crt" = {
    sopsFile = ../secrets.yaml;
    owner = config.services.caddy.user;
    restartUnits = [ "caddy.service" ];
  };
};

services = {
  duckdns = {
    enable = true;
    tokenFile = config.sops.secrets."duckdns.token".path;
    domains = [ "cloverp" ];
  };

  caddy = {
    enable = true;
    email = "clover+acme@isons.org";
    logFormat = ''
      level ERROR
      format journald {
        wrap console
      }
    '';
    openFirewall = true;
  };
};

}
