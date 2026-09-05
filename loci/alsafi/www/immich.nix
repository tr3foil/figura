{ config, ... }: let
  cfg = config.services.immich;
in {

services = {
  immich = {
    enable = true;
    host = "localhost";
    openFirewall = false;
  };

  caddy.virtualHosts."pics.clover.isons.org".extraConfig = ''
    reverse_proxy ${cfg.host}:${toString cfg.port}
  '';

  tinyauth.settings = {
    OIDC_CLIENTS_IMMICH_NAME = "Immich";
    OIDC_CLIENTS_IMMICH_TRUSTEDREDIRECTURIS = "https://pics.clover.isons.org/auth/login,https://pics.clover.isons.org/user-settings,https://pics.clover.isons.org/api/oauth/mobile-redirect,app.immich:///oauth-callback";
  };
};

}
