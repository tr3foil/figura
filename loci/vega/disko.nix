{

disko.devices = {
  disk.main = {
    type = "disk";
    device = "/dev/nvme0n1";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          size = "500M";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/efi";
            mountOptions = [ "umask=0077" "fmask=0022" "dmask=0022" ];
          };
        };
        luks = {
          size = "100%";
          content = {
            type = "luks";
            name = "crypted";
            settings.allowDiscards = true;
            askPassword = true;
            content = {
              type = "lvm_pv";
              vg = "pool";
            };
          };
        };
      };
    };
  };
  lvm_vg = {
    pool = {
      type = "lvm_vg";
      lvs = {
        nixos = {
          size = "100%";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
            mountOptions = [ "defaults" "lazytime" "noatime" ];
          };
        };
        swap = {
          size = "16G";
          content = {
            type = "swap";
            discardPolicy = "both";
            resumeDevice = true;
          };
        };
      };
    };
  };
};

}
