{ config, lib, pkgs, ... }: let
  cfg = config.www;
in {

imports = [
  ./webdav.nix
  ./calibre.nix
  ./peertube.nix
  ./immich.nix
  ./cloverpad.nix
  ./auth
  ./acme.nix
];

options = {
  www = {
    enable = lib.mkEnableOption "hosting webservices, reachable externally!";
    domain = lib.mkOption {
      default = null;
      type = lib.types.nullOr lib.types.str;
    };
  };
};

config = {
  sops.secrets = {
    "duckdns.token".sopsFile = ../secrets.yaml;
    "caddy-mtls_client-ca.crt" = {
      sopsFile = ../secrets.yaml;
      owner = config.services.caddy.user;
      restartUnits = [ "caddy.service" ];
    };
  };

  www = {
    enable = true;
    domain = "trefoil.gay";
  };

  services = {
    duckdns = {
      inherit (cfg) enable;
      tokenFile = config.sops.secrets."duckdns.token".path;
      domains = [ "cloverp" ];
    };

    caddy = {
      inherit (cfg) enable;
      package = pkgs.caddy.withPlugins {
        plugins = [ "github.com/caddy-dns/acmedns@v0.7.0" ];
        hash = "sha256-gPOoyci0lQsDInBQgyjlSw4/N3MQjO/zDjgcYYTl7IE=";
      };
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

  assertions = [
    { assertion = cfg.enable -> !isNull cfg.domain;
      message = "domain must be set to enable web services";
    }
  ];
};

}
