{ config, ... }: let
  domain = "acme-dns.${config.www.domain}";
in {

sops.secrets."acme-dns.json" = {
  sopsFile = ../secrets.yaml;
  owner = config.services.caddy.user;
  reloadUnits = [ "caddy.service" ];
};

services = {
  acme-dns = {
    enable = config.www.enable;
    settings = {
      general = {
        inherit domain;
        nsname = domain;
        nsadmin = "clover+acme.isons.org";
        listen = "10.0.0.73:53";
        records = [
          "${domain}. A 141.148.160.13"
          "${domain}. NS ${domain}."
        ];
      };
      api = {
        ip = "[::1]";
        port = 53933;
        disable_registration = false;
        tls = "none"; # since only listening on localhost
      };
      database = {
        engine = "postgres";
        connection = "postgres://acme-dns@/acme-dns?host=/run/postgresql";
      };
      logconfig.loglevel = "debug";
    };
  };

  postgresql = {
    enable = true;
    ensureDatabases = [ "acme-dns" ];
    ensureUsers = [
      { name = "acme-dns";
        ensureDBOwnership = true;
      }
    ];
  };

  caddy = {
    globalConfig = ''
      acme_dns acmedns ${config.sops.secrets."acme-dns.json".path}
    '';
    virtualHosts."*.${config.www.domain}".extraConfig = ''
      # create a wildcard tls cert
      abort
    '';
  };
};

networking.firewall = {
  allowedTCPPorts = [ 53 ];
  allowedUDPPorts = [ 53 ];
};

}
