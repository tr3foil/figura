{ config, lib, ... }: {

# TODO: can this be a wrapper?
# TODO: test; use `niri validate`
# TODO: set colors with nix

users.users.cison.maid = lib.mkIf config.programs.niri.enable {
  file.xdg_config."niri/config.kdl".source = ./config.kdl;
};

}
