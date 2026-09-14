{ config, pkgs, lib, ... }: let
  cfg = config.zap;
in {

options.zap.enable = lib.mkEnableOption "zap";

config = {
  wrappers.zap = lib.mkIf cfg.enable {
    basePackage = pkgs.zap;
    env = {
      _JAVA_AWT_WM_NONREPARENTING = "1";
      _JAVA_OPTIONS = "-Dawt.useSystemAAFontSettings=lcd";
    };
  };
  users.users.cison.maid.packages = [ pkgs.firefox ];

  assertions = [
    { assertion = cfg.enable -> config.head.graphical;
      message = "zap needs a desktop to run on";
    }
  ];
};

}
