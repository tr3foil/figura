{ config, inputs, lib, pkgs, ... }: {

imports = [
  inputs.lanzaboote.nixosModules.lanzaboote
  ./hardware.nix
  ./disko.nix
  ./tlp.nix
  ./secure-suspend.nix
];

head.graphical = true;

system.stateVersion = "25.05";

# Control screen backlight, must be in video group
hardware.acpilight.enable = true;
users.users.cison.extraGroups = [ "video" ];

hardware.bluetooth.enable = true;

networking.networkmanager.enable = true;

# For working with Secure Boot
environment.systemPackages = [ pkgs.sbctl ];

boot = {
  lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };
  loader = {
    systemd-boot = {
      enable = lib.mkForce false;
      configurationLimit = 5;
      editor = false;
    };
    efi = {
      efiSysMountPoint = "/efi";
      canTouchEfiVariables = true;
    };
  };
};

# This bitch is secured with fde, we can autologin
users.mutableUsers = false;
users.users.cison.initialHashedPassword = lib.mkForce null;
services.greetd.settings = {
  initial_session = {
    command = "niri-session";
    user = "cison";
  };
  # Drop to shell if session is killed
  default_session = lib.mkForce {
    command = lib.getExe config.users.users.cison.shell;
    user = "cison";
  };
};
# Passwordless, so allow polkit actions without auth as well
security.polkit.extraConfig = ''
  polkit.addRule(function(action, subject) {
    if (subject.isInGroup("wheel")) return polkit.Result.YES;
  });
'';

services.logind.settings.Login = {
  lidSwitch = "suspend-then-hibernate";
  # Stop accidentally shutting off
  powerKey = "ignore";
  powerKeyLongPress = "poweroff";
};

home-manager.users.cison.graphical.games = true;

}
