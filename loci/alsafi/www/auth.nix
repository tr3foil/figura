{ config, ... }: let
  cfgPi = config.services.pocket-id;
  cfgTa = config.services.tinyauth;
in {

sops.secrets = {
  "pocket-id_encryption.key" = {
    sopsFile = ../secrets.yaml;
    owner = cfgPi.user;
  };
  "tinyauth.env" = {
    sopsFile = ../secrets.yaml;
    owner = cfgTa.user;
    restartUnits = [ "tinyauth.service" ];
  };
};

services = {
  pocket-id = {
    enable = true;
    settings = {
      HOST = "localhost";
      PORT = 5059;
      APP_URL = "https://id.clover.isons.org";
      DB_CONNECTION_STRING = "postgres://pocket-id@/pocket-id?host=/run/postgresql";
      ALLOW_INSECURE_CALLBACK_URLS = false;
      ANALYTICS_DISABLED = true;
      VERSION_CHECK_DISABLED = true;
    };
    credentials = {
      ENCRYPTION_KEY = config.sops.secrets."pocket-id_encryption.key".path;
    };
  };

  tinyauth = {
    enable = true;
    environmentFile = config.sops.secrets."tinyauth.env".path;
    settings = rec {
      SERVER_ADDRESS = "localhost";
      SERVER_PORT = 3962;
      APPURL = "https://auth.clover.isons.org";
      DATABASE_PATH = "postgres://tinyauth@/tinyauth?host=/run/postgresql";
      OAUTH_PROVIDERS_POCKETID_AUTHURL = cfgPi.settings.APP_URL + "/authorize";
      OAUTH_PROVIDERS_POCKETID_TOKENURL = cfgPi.settings.APP_URL + "/api/oidc/token";
      OAUTH_PROVIDERS_POCKETID_USERINFOURL = cfgPi.settings.APP_URL + "/api/oidc/userinfo";
      OAUTH_PROVIDERS_POCKETID_REDIRECTURL = APPURL + "/api/oauth/callback/pocketid";
      OAUTH_PROVIDERS_POCKETID_SCOPES = "openid email profile groups";
      OAUTH_PROVIDERS_POCKETID_NAME = "Pocket ID";
      OAUTH_AUTOREDIRECT = "pocketid";
    };
  };

  postgresql = {
    enable = true;
    ensureDatabases = [
      "pocket-id"
      "tinyauth"
    ];
    ensureUsers = [
      { name = "pocket-id";
        ensureDBOwnership = true;
      }
      { name = "tinyauth";
        ensureDBOwnership = true;
      }
    ];
  };

  caddy.virtualHosts = {
    ${cfgPi.settings.APP_URL}.extraConfig = ''
      reverse_proxy ${cfgPi.settings.HOST}:${toString cfgPi.settings.PORT}
    '';
    ${cfgTa.settings.APPURL}.extraConfig = ''
      reverse_proxy ${cfgTa.settings.SERVER_ADDRESS}:${toString cfgTa.settings.SERVER_PORT}
    '';
  };
};

}
