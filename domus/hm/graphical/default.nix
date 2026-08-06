{ config, lib, pkgs, ... }: with lib; {

imports = [
  ./games.nix
];

options.graphical = {
  enable = mkEnableOption (mdDoc "graphical user environment");
  games = mkEnableOption (mdDoc "games :)");
};

config = mkMerge [
  ( mkIf config.graphical.enable {
    home.packages = with pkgs; [
      # Fonts
      nerd-fonts.blex-mono
      noto-fonts-color-emoji
      # Social
      signal-desktop

      # Tools
      gimp
      inkscape
      kicad-small

      # Audio
      pwvucontrol
      crosspipe
      easyeffects

      # Media
      plex-desktop
      mpv
      playerctl
      mpd
      mpdris2
      mpc
      ncmpcpp

      # Utils
      wl-clipboard
      xdg-utils
      imv
    ];
  } )

  {
    assertions = with config.graphical; [
      {
        assertion = games -> enable;
        message = "games need a graphical environment to run in";
      }
    ];
  }
];

}
