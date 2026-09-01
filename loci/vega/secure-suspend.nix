{ ... }: let
  secure-suspend = fetchTarball {
    url = "https://codeberg.org/iblech/secure-suspend/archive/107e64ead3f249c820b54559f8a3385fba5bb99d.tar.gz";
    sha256 = "sha256-/m0ws817yUUGl4sOjeYmKlRPuW4VN4NF4Unq9kKDaGM=";
  };
in {

imports = [
  "${secure-suspend}/secure-suspend.nix"
];

security.secureSuspend.enable = true;

}
