{ config, ... }: let
  cfg = config.services.immich;
  cfgTa = config.services.tinyauth;
in {

services = {
  immich = {
    enable = true;
    host = "localhost";
    openFirewall = false;
  };

  caddy.virtualHosts = {
    "pics.clover.isons.org".extraConfig = ''
      forward_auth ${cfgTa.settings.SERVER_ADDRESS}:${toString cfgTa.settings.SERVER_PORT} {
        uri /api/auth/caddy
      }
      reverse_proxy ${cfg.host}:${toString cfg.port}
    '';

    # subdomain for immich app with mtls instead of tinyauth middleware
    "m.pics.clover.isons.org".extraConfig = ''
      tls {
        client_auth {
          trust_pool file ${config.sops.secrets."caddy-mtls_client-ca.crt".path}
        }
      }
      reverse_proxy ${cfg.host}:${toString cfg.port}
    '';
  };

  tinyauth.settings = {
    OIDC_CLIENTS_IMMICH_NAME = "Immich";
    OIDC_CLIENTS_IMMICH_TRUSTEDREDIRECTURIS = "https://pics.clover.isons.org/auth/login,https://pics.clover.isons.org/user-settings,https://pics.clover.isons.org/api/oauth/mobile-redirect,app.immich:///oauth-callback";
  };
};

}
