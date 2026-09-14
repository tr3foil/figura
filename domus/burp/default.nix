{ config, pkgs, lib, ... }: let
  cfg = config.burpsuite;
in {

options.burpsuite.enable = lib.mkEnableOption "burpsuite";

config = {
  wrappers.burpsuite = lib.mkIf cfg.enable {
    basePackage = pkgs.burpsuite;
    env = {
      _JAVA_AWT_WM_NONREPARENTING = "1";
      _JAVA_OPTIONS = "-Dawt.useSystemAAFontSettings=lcd";
    };
  };

  assertions = [
    { assertion = cfg.enable -> config.head.graphical;
      message = "burpsuite needs a desktop to run on";
    }
  ];
};

}
