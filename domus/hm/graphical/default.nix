{ config, lib, ... }: with lib; {

imports = [
  ./games.nix
];

options.graphical = {
  enable = mkEnableOption (mdDoc "graphical user environment");
  games = mkEnableOption (mdDoc "games :)");
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
