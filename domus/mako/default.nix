{ config, lib, pkgs, inputs, ... }: {

options = {
  desktop.mako.enable = lib.mkEnableOption "mako notification daemon" // {
    default = config.head.graphical;
  };
};

config = lib.mkIf config.desktop.mako.enable {
  users.users.cison.maid = {
    packages = [ pkgs.mako ];
    systemd.packages = [ pkgs.mako ];

    file.xdg_data."dbus-1/services/fr.emersion.mako.service" = {
      source = pkgs.mako + "/share/dbus-1/services/fr.emersion.mako.service";
    };
    # TODO: this should be a wrapper (with a test)
    file.xdg_config."mako/config".text = with inputs.phosphor.lib.colors; ''
      anchor=top-right
      background-color=#${black}
      border-color=#${blackBright}
      border-radius=10
      border-size=1
      default-timeout=5000
      font=IBM Plex Mono
      ignore-timeout=true
      layer=overlay
      margin=10
      markup=true
      max-visible=10
      padding=5
      progress-color=over #${green}
      text-color=#${white}
      height=600

      [mode=dnd]
      invisible=true
    '';
  };

  assertions = [
    { assertion = config.desktop.mako.enable -> config.head.graphical;
      message = "can't have a notification daemon without a desktop!";
    }
  ];
};

}
