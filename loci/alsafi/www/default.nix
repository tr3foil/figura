{ config, pkgs, inputs, ... }: {

imports = [
  ./webdav.nix
  ./calibre.nix
  ./peertube.nix
  ./immich.nix
];

sops.secrets = {
  "godaddy.key".sopsFile = ../secrets.yaml;
  "godaddy.secret".sopsFile = ../secrets.yaml;
  "duckdns.token".sopsFile = ../secrets.yaml;
};

services = {
  duckdns = {
    enable = true;
    tokenFile = config.sops.secrets."duckdns.token".path;
    domains = [ "cloverp" ];
  };

  nginx = {
    enable = true;
    recommendedTlsSettings = true;
    virtualHosts."clover.isons.org" = {
      root = inputs.cloverpad.packages.${pkgs.stdenv.hostPlatform.system}.default + "/site";
      forceSSL = true;
      useACMEHost = "clover.isons.org";
    };
  };
};

users.users.nginx.extraGroups = [ "acme" ];

security.acme = {
  defaults = {
    email = "clover+acme@isons.org";
    dnsProvider = "godaddy";
    credentialFiles = {
      "GODADDY_API_KEY_FILE" = config.sops.secrets."godaddy.key".path;
      "GODADDY_API_SECRET_FILE" = config.sops.secrets."godaddy.secret".path;
    };
  };
  certs."clover.isons.org".extraDomainNames = [
    "clover.isons.org"
    "*.clover.isons.org"
  ];
  acceptTerms = true;
};

networking.firewall.allowedTCPPorts = [ 80 443 ];

}
