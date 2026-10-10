{ config, ... }: let
  cfg = config.services.immich;
  cfgTa = config.services.tinyauth;
  domain = "pics.${config.www.domain}";
in {

sops.secrets = {
  "immich/client.id" = {
    sopsFile = ../secrets.yaml;
    owner = cfg.user;
    restartUnits = [ "immich-server.service" ];
  };
  "immich/client.secret" = {
    sopsFile = ../secrets.yaml;
    owner = cfg.user;
    restartUnits = [ "immich-server.service" ];
  };
};

services = {
  immich = {
    enable = config.www.enable;
    host = "localhost";
    openFirewall = false;
    settings = {
      server = {
        externalDomain = "https://" + domain;
        publicUsers = false;
      };
      ffmpeg = {
        acceptedAudioCodecs = [ "aac" "opus" ];
        acceptedVideoCodecs = [ "av1" "hevc" ];
        preset = "fast";
        targetResolution = "original";
        targetVideoCodec = "hevc";
      };
      metadata.faces.import = true;
      oauth = {
        enabled = true;
        allowInsecureRequests = false;
        autoLaunch = true;
        autoRegister = false;
        buttonText = "Login with Tinyauth";
        clientId._secret = config.sops.secrets."immich/client.id".path;
        clientSecret._secret = config.sops.secrets."immich/client.secret".path;
        issuerUrl = cfgTa.settings.APPURL;
      };
      passwordLogin.enabled = false;
      user.deleteDelay = 30;
    };

  };

  immich-public-proxy = {
    enable = cfg.enable;
    port = 61505;
    immichUrl = "http://${cfg.host}:${toString cfg.port}";
    settings = {
      # follow download rules set per share in immich
      allowDownload = 1;
      # show description in lightbox caption
      showMetadata.description.caption = true;
    };
  };

  caddy.virtualHosts = {
    ${domain}.extraConfig = ''
      # immich public proxy paths
      @public path /share /share/* /s/*
      handle @public {
        reverse_proxy localhost:${toString config.services.immich-public-proxy.port}
      }

      # everything else protected with tinyauth
      handle {
        forward_auth ${cfgTa.settings.SERVER_ADDRESS}:${toString cfgTa.settings.SERVER_PORT} {
          uri /api/auth/caddy
        }
        reverse_proxy ${cfg.host}:${toString cfg.port}
      }
    '';

    # subdomain for immich app with mtls instead of tinyauth middleware
    "m-${domain}".extraConfig = ''
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
