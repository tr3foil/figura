{ config, pkgs, inputs, ... }: {

imports = [
  ./webdav.nix
  ./calibre.nix
  ./peertube.nix
  ./immich.nix
];

sops.secrets = {
  "duckdns.token".sopsFile = ../secrets.yaml;
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
    virtualHosts."clover.isons.org" = {
      extraConfig = let
        cloverpad = inputs.cloverpad.packages.${pkgs.stdenv.hostPlatform.system}.default;
      in ''
        root ${cloverpad}/site
        file_server
      '';
    };
    openFirewall = true;
  };
};

}
