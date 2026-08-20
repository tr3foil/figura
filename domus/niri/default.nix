{ config, inputs, lib, pkgs, ... }: {

# TODO: can this be a wrapper?
# TODO: test; use `niri validate`

users.users.cison.maid = lib.mkIf config.programs.niri.enable {
  file.xdg_config."niri/config.kdl".source = pkgs.runCommand "config.kdl"
      inputs.phosphor.lib.colors
      "substituteAll ${./config.kdl} $out";
};

}
