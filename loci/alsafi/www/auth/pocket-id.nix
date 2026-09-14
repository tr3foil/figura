{ config, inputs, ... }: let
  cfg = config.services.pocket-id;
  domain = "id.${config.www.domain}";
in {

sops.secrets."pocket-id_encryption.key" = {
  sopsFile = ../../secrets.yaml;
  owner = cfg.user;
};

services = {
  pocket-id = {
    enable = config.www.enable;
    settings = {
      HOST = "localhost";
      PORT = 5059;
      APP_URL = "https://${domain}";
      DB_CONNECTION_STRING = "postgres://pocket-id@/pocket-id?host=/run/postgresql";
      ALLOW_INSECURE_CALLBACK_URLS = false;
      ANALYTICS_DISABLED = true;
      VERSION_CHECK_DISABLED = true;
      UI_CONFIG_DISABLED = true;
      ACCENT_COLOR = "#${inputs.phosphor.lib.colors.green}";
    };
    credentials = {
      ENCRYPTION_KEY = config.sops.secrets."pocket-id_encryption.key".path;
    };
  };

  postgresql = {
    enable = true;
    ensureDatabases = [ "pocket-id" ];
    ensureUsers = [
      { name = "pocket-id";
        ensureDBOwnership = true;
      }
    ];
  };

  caddy.virtualHosts.${cfg.settings.APP_URL}.extraConfig = ''
    reverse_proxy ${cfg.settings.HOST}:${toString cfg.settings.PORT}
  '';
};

}
