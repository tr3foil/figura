{ pkgs, config, lib, inputs, ... }: let
  configHM = config.home-manager.users.cison;
in {

imports = [
  ./head.nix
  ./pyrosite.nix
  ./hosts.nix
  ./mouse.nix
  ./lix.nix
  ./northstarProton
];

# I'm a huge fan of opaque binary blobs
hardware.enableAllFirmware = true;

mouse.edpi = 1100;

mouse.mice = {
  ploopy = {
    udevID = "mouse:usb:v5043p4d6f:name:PloopyCo Mouse:";
    swayID = "20547:19823:PloopyCo_Mouse";
    dpi = 12000;
    refresh = 1000;
  };
  razer = {
    udevID = "mouse:bluetooth:v1532p0061:name:Razer Atheris Mouse:";
    swayID = "5426:97:Razer_Atheris_Mouse";
    dpi = 7200;
    refresh = 1000;
  };
};

sops = {
  defaultSopsFile = ./secrets.yaml;
  secrets.testSecret = {};
};

nix = {
  settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "root" "cison" ];
    auto-optimise-store = true;
    flake-registry = "";
  };
  gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
  registry = {
    figura = {
      from = {
        type = "indirect";
        id = "figura";
      };
      to = {
        type = "github";
        owner = "tr3foil";
        repo = "figura";
        ref = "main";
      };
      exact = false;
    };
    templates = {
      from = {
        type = "indirect";
        id = "templates";
      };
      to = {
        type = "github";
        owner = "tr3foil";
        repo = "templates";
        ref = "main";
      };
      exact = false;
    };
  };
};

documentation = {
  info.enable = false;
  # Generating man cache is really slow
  man.cache.enable = false;
};

networking.firewall.enable = true;
networking.useNetworkd = true;

time.timeZone = "America/Phoenix";

# Internationalisation properties.
i18n = {
  defaultLocale = "en_US.UTF-8";
  extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };
};

users.users.cison = {
  isNormalUser = true;
  description = "Clover";
  extraGroups = [
    "networkmanager"
    "wheel"
    "disk"
    "keys"
  ] ++ lib.optional config.programs.gamemode.enable "gamemode";
  openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINtQWB9sas10nnFPFaWYMTY+8QrXaJ64bBJz/iGnCtFO cison@sol"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAaOgvgz6SPLK488uiy+U0Vpq2szWzsS6RuvQZ8w9qWP cison@vega"
    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIEmwPMMPsx2kNI60yFBGKNnfW6UHsOxLN07IFCjL52iqAAAABHNzaDo= clover@isons.org"
  ];
  initialHashedPassword = "";
};

security = {
  polkit.enable = true;
  rtkit.enable = true;
  sudo.enable = false;
  # workaround for systemd-run0 <https://github.com/NixOS/nixpkgs/issues/361592>
  pam.services.systemd-run0 = {
    setEnvironment = true;
    pamMount = false;
  };
};

# Sorry Richard
nixpkgs.config.allowUnfree = true;

environment.systemPackages = with pkgs; [
  coreutils-full
  git
  vim
  sops
  cntr

  # Add completion for 'nixos-version --configuration-revision'
  (nix-bash-completions.overrideAttrs (_: prev: {
    patches = prev.patches ++ [ (fetchpatch {
      url = "https://patch-diff.githubusercontent.com/raw/hedning/nix-bash-completions/pull/27.patch";
      hash = "sha256-VaUDLMJqITRmBFrZ9Y6nJGHGCCA8yEptqBUprqIQpng=";
    }) ];
  }))

  foot.terminfo
  alacritty.terminfo

  usbutils pciutils
  lshw
  lm_sensors

  ntfs3g

  zip unzip p7zip xz gzip bzip2
] ++ lib.optional config.services.smartd.enable pkgs.smartmontools;

fonts.packages = [ pkgs.unifont ];

console = {
  packages = [ pkgs.terminus_font ];
  font = "Lat2-Terminus16";
  colors = with inputs.pyroscheme.lib.colors; [
    black
    red
    green
    yellow
    blue
    magenta
    cyan
    white
    blackBright
    redBright
    greenBright
    yellowBright
    blueBright
    magentaBright
    cyanBright
    whiteBright
  ];
};

programs.nano.enable = false;

programs.yubikey-manager.enable = true;

services = {
  smartd = {
    enable = true;
    notifications.x11.enable = config.head.graphical;
  };

  openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
    openFirewall = true;
    ports = [ 22 26656 ];
  };

  # Enable (pgp) smartcard support
  pcscd.enable = !config.head.headless;
};

}
