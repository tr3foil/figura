{ pkgs, inputs, ... }: {

services.caddy.virtualHosts."clover.isons.org" = {
  extraConfig = let
    cloverpad = inputs.cloverpad.packages.${pkgs.stdenv.hostPlatform.system}.default;
  in ''
    root ${cloverpad}/site
    file_server
  '';
};

}
