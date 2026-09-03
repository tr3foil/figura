{ config, ... }: {

sops.secrets."peertube" = {
  sopsFile = ../secrets.yaml;
  # owner = config.services.peertube.user;
  # restartUnits = [ "peertube.service" ];
};

# TODO: either use nginx proxied through caddy for peertube or figure out how to proxy peertube with caddy
# see <https://gist.github.com/toby3d/ad2f20f31d1c71a51914045efd0a9a61>
# see <https://caddy.community/t/peertube-video-platform-nginx-caddy/15276>

services = {
  peertube = {
    enable = false;
    enableWebHttps = true;
    listenWeb = 443;
    settings = {
      listen.hostname = "127.0.0.1"; # configureNginx expects ipv4 loopback
    };
    secrets.secretsFile = config.sops.secrets."peertube".path;
    redis.createLocally = true;
    database.createLocally = true;
    localDomain = "tv.clover.isons.org";
  };
};

}
