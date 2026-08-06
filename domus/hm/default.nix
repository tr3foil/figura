{ pkgs, config, ... }: {

imports = [
  ./graphical
  ./prompt.nix
];

home = {
  username = "cison";
  homeDirectory = "/home/cison";

  stateVersion = "22.11";

  # Verify Home Manager and Nixpkgs are on same release ver
  enableNixpkgsReleaseCheck = true;

  sessionVariables = {
    EDITOR = "vim";
    # Set less options
    LESS = "-FR";
    PAGER = "less";
  };

  shellAliases = {
    # ls shorthand and auto-coloring
    ls = "ls --color=auto";
    la = "ls -A";
    ll = "ls -l";
    "l." = "ls -d .*";

    # cd shorthand
    ".." = "cd ..";
  };
};

# Home Manager managed programs
programs = {
  # Manage HM with HM
  home-manager.enable = true;

  # Make bash work with HM
  bash.enable = true;

  gpg = {
    enable = true;
    mutableKeys = true;
    mutableTrust = true;
    settings = {
      keyid-format = "none";
      with-subkey-fingerprint = true;
    };
  };

  git = {
    enable = true;
    signing = {
      key = "${config.home.homeDirectory}/.ssh/id_ed25519";
      format = "ssh";
      signByDefault = true;
    };
    settings = {
      user = {
        name = "Clover Ison";
        email = "clover@isons.org";
      };
      aliases = {
        l = "log --graph";
        hash = "log -n 1 --format=%H";
      };
      init.defaultBranch = "main";
      log = {
        abbrevCommit = true;
        showSignature = true;
      };
      diff.colorMoved = "default";
      gpg.ssh.allowedSignersFile = "${config.home.homeDirectory}/.ssh/allowed_signers";
    };
    ignores = [
      "*.swp"
    ];
  };

  delta = {
    enable = true;
    enableGitIntegration = true;
  };
};

# Home Manager managed services
services = {
  gpg-agent = {
    enable = true;
    enableBashIntegration = true;
    enableScDaemon = true;
    enableSshSupport = true;
    sshKeys = [ "3C305675F93CC000802C4DE9F6DDF464ACDD3DE3" ];
    grabKeyboardAndMouse = true;
    pinentry.package = pkgs.pinentry-qt;
  };

  # Connect to phone with kdeconnect app
  kdeconnect = {
    enable = true;
    indicator = true;
  };
};

# XDG user directories
xdg = {
  enable = true;
  userDirs = {
    enable = true;
    setSessionVariables = true;
    desktop = "${config.home.homeDirectory}/desktop";
    documents = "${config.home.homeDirectory}/documents";
    download = "${config.home.homeDirectory}/downloads";
    pictures = "${config.home.homeDirectory}/pictures";
  };
};

home.packages = with pkgs; [
  # Utilities
  coreutils-full
  psmisc
  file
  libqalculate

  # Blazingly fast
  fd
  dust

  # Drip
  bottom
  fastfetch
];

}
