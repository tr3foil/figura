{ config, ... }: let
  cfg = config.services.tinyauth;
  cfgPi = config.services.pocket-id;
in {

sops.secrets."tinyauth.env" = {
    sopsFile = ../../secrets.yaml;
    owner = cfg.user;
    restartUnits = [ "tinyauth.service" ];
};

services = {
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
    ensureDatabases = [ "tinyauth" ];
    ensureUsers = [
      { name = "tinyauth";
        ensureDBOwnership = true;
      }
    ];
  };

  caddy.virtualHosts.${cfg.settings.APPURL}.extraConfig = ''
    reverse_proxy ${cfg.settings.SERVER_ADDRESS}:${toString cfg.settings.SERVER_PORT}
  '';
};

}
