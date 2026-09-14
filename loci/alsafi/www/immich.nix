{ config, ... }: let
  cfg = config.services.immich;
  cfgTa = config.services.tinyauth;
  domain = "pics.${config.www.domain}";
in {

services = {
  immich = {
    enable = config.www.enable;
    host = "localhost";
    openFirewall = false;
  };

  caddy.virtualHosts = {
    ${domain}.extraConfig = ''
      forward_auth ${cfgTa.settings.SERVER_ADDRESS}:${toString cfgTa.settings.SERVER_PORT} {
        uri /api/auth/caddy
      }
      reverse_proxy ${cfg.host}:${toString cfg.port}
    '';

    # subdomain for immich app with mtls instead of tinyauth middleware
    "m.${domain}".extraConfig = ''
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
    OIDC_CLIENTS_IMMICH_TRUSTEDREDIRECTURIS = "https://${domain}/auth/login,https://${domain}/user-settings,https://${domain}/api/oauth/mobile-redirect,app.immich:///oauth-callback";
    APPS_IMMICH_CONFIG_DOMAIN = domain;
    APPS_IMMICH_OAUTH_GROUPS = "photographers";
  };
};

}
