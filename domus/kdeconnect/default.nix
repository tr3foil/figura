{ config, lib, ... }: let
  cfg = config.programs.kdeconnect;
in {

options = {
  programs.kdeconnect = {
    indicator = lib.mkEnableOption "kdeconnect-indicator" // {
      default = cfg.enable;
    };
  };
};

config = {
  programs.kdeconnect.enable = lib.mkDefault config.head.graphical;

  users.users.cison.maid = lib.mkIf cfg.enable {
    packages = [ cfg.package ];
    systemd = {
      packages = [ cfg.package ];
      # no upstream service definition for indicator :(
      services.kdeconnect-indicator = lib.mkIf cfg.indicator {
        description = "kdeconnect-indicator";
        after = [ "graphical-session.target" ];
        partOf = [ "graphical-session.target" ];
        wantedBy = [ "graphical-session.target" ];
        path = [ cfg.package ];
        script = "kdeconnect-indicator";
      };
    };
  };

  assertions = [
    { assertion = cfg.enable -> config.head.graphical;
      message = "kdeconnect needs a desktop!";
    }
    { assertion = cfg.indicator -> cfg.enable;
      message = "kdeconnect-indicator needs kdeconnect!";
    }
  ];
};

}
