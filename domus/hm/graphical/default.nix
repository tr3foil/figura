{ config, lib, ... }: with lib; {

imports = [
  ./games.nix
];

options.graphical = {
  enable = mkEnableOption "graphical user environment";
  games = mkEnableOption "games :)";
};

config = {
  assertions = with config.graphical; [
    {
      assertion = games -> enable;
      message = "games need a graphical environment to run in";
    }
  ];
};

}
