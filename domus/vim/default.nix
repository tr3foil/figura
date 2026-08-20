{ config, pkgs, ... }: {

wrappers.vim = {
  basePackage = pkgs.vim;
  prependFlags = let
    inherit (config.users.users.cison) home;
    vimDir = ./vimdir;
    stateDir = home + "/.local/state/vim";
    vimrc = pkgs.runCommand "vimrc" {
      inherit vimDir stateDir;
    } "substituteAll ${./vimrc} $out";
  in [ "-u" vimrc ];
};

}
