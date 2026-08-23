{ config, lib, pkgs, ... }: {

# pacakges for desktop environments

users.users.cison.maid = lib.mkIf config.head.graphical {
  packages = [
    # Fonts
    pkgs.nerd-fonts.blex-mono
    pkgs.noto-fonts-color-emoji

    # Social
    pkgs.signal-desktop

    # Tools
    pkgs.gimp
    pkgs.inkscape
    pkgs.kicad-small

    # Audio
    pkgs.pwvucontrol
    pkgs.crosspipe
    pkgs.easyeffects

    # Media
    pkgs.plex-desktop
    pkgs.mpv
    pkgs.playerctl
    pkgs.mpd
    pkgs.mpdris2
    pkgs.mpc
    pkgs.ncmpcpp

    # Utils
    pkgs.wl-clipboard
    pkgs.xdg-utils
    pkgs.imv
  ];
};

}
