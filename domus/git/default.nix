{ config, lib, pkgs, ... }: {

# TODO: wrapper?
# TODO: test

users.users.cison.maid = {
  packages = [ pkgs.git pkgs.delta ];
  file.xdg_config."git/config" = {
    source = pkgs.runCommand "config"
      { sshKeygen = lib.getExe' pkgs.openssh "ssh-keygen";
        delta = lib.getExe pkgs.delta;
        sshHome = config.users.users.cison.home + "/.ssh";
      }
      "substituteAll ${./config} $out";
  };
  file.xdg_config."git/ignore".source = ./ignore;
};

}
