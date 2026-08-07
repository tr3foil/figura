{ config, lib, inputs, pkgs, ... }: let
  wrappersEval = inputs.wrapper-manager.lib {
    inherit pkgs;
    modules = [ { inherit (config) wrappers; } ];
  };
in {

imports = [
  ./ripgrep
  ./vim
  ./alacritty
  ./foot
  ./fuzzel
  ./readline
  ./xcompose
  ./ssh
  ./niri
  ./mako
];

options = {
  wrappers = lib.mkOption {
    # TODO: specify type
    description = "Wrapper declarations for wrapper manager";
  };
};

config = {
  users.users.cison.packages = [
    wrappersEval.config.build.toplevel
    pkgs.flow-control
    pkgs.nixd
    pkgs.gnupg

    # Utilities
    pkgs.coreutils-full
    pkgs.psmisc
    pkgs.file
    pkgs.libqalculate

    # Blazingly fast
    pkgs.fd
    pkgs.dust

    # Drip
    pkgs.bottom
    pkgs.fastfetch
  ] ++ lib.optionals config.head.graphical [
    (pkgs.ungoogled-chromium.override { enableWideVine = true; })
    pkgs.libreoffice
    pkgs.vesktop
  ];
};

}
