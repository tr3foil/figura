{ config, inputs, lib, pkgs, ... }: {

# TODO: this can be a wrapper

users.users.cison.maid = lib.mkIf config.programs.niri.enable {
  file.xdg_config = {
    "waybar/style.css".source = let
      phosphor = pkgs.runCommand "waybar-phosphor.css"
        inputs.phosphor.lib.colors
        "substituteAll ${./phosphor.css} $out";
    in pkgs.runCommand "waybar-style.css" {
      inherit phosphor;
    } "substituteAll ${./style.css} $out";

    "waybar/config".source = pkgs.runCommand "waybar-config" {
      pwvucontrol = lib.getExe pkgs.pwvucontrol;
    } "substituteAll ${./config} $out";
  };

  systemd.packages = [ pkgs.waybar ];
};

}

# TODO: fix this script and use it:
  # CURRENT=$(pactl list sinks | rg -o "Active Port: [a-z\-]+")

  # if [ "$CURRENT" = "Active Port: analog-output-lineout" ]; then
  #   pactl set-sink-port alsa_output.pci-0000_0b_00.4.analog-stereo analog-output-headphones
  # elif [ "$CURRENT" = "Active Port: analog-output-headphones" ]; then
  #   pactl set-sink-port alsa_output.pci-0000_0b_00.4.analog-stereo analog-output-lineout
  # else echo "wtf"; false
  # fi
