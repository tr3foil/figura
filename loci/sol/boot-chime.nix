{ pkgs, ... }: {

systemd.services.boot-chime = {
  enable = false;
  wantedBy = [ "sound.target" ];
  after = [ "sound.target" ];

  environment = {
    RIFFS = pkgs.fetchFromGitHub {
      owner = "tr3foil";
      repo = "seinfeld-riffs";
      rev = "40e0e69bbb2fbaae5829873fea7bb2d8f3bb4531";
      hash = "sha256-7PxTcy/jvRoIT+8eyG2oMaYI2Unz+P06laWKiJqPUnU=";
    };
    SDL_AUDIODRIVER = "alsa";
    AUDIODEV = "hdmi:CARD=HDMI,DEV=3";
  };

  path = [
    pkgs.ffmpeg
  ];

  script = ''
    RIFF=$(shuf -n 1 -e $RIFFS/riffs/short/*)
    ffplay "$RIFF" -hide_banner -autoexit -vn -nodisp
  '';
};

}
