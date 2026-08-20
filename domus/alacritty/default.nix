{ config, pkgs, lib, inputs, ... }: {

wrappers.alacritty = lib.mkIf config.head.graphical {
  basePackage = pkgs.alacritty;
  prependFlags = let
    colors = lib.mapAttrs (_: x: "#" + x) inputs.phosphor.lib.colors;
    config = pkgs.writeText "alacritty.toml"
      (import ./config.nix colors);
  in [ "--config-file" config ];
};

}
