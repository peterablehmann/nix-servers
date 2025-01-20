{ config
, ...
}:
{
  disko.devices = {
    disk = {
      root = {
        device = "/dev/vdb";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              label = "EFI";
              type = "EF00";
              size = "200M";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            root = {
              label = "NIXOS";
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };
      restic = {
        device = "/dev/vda";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            data = {
              label = "RESTIC";
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = config.services.restic.server.dataDir;
              };
            };
          };
        };
      };
      syncthing = {
        device = "/dev/vdc";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            data = {
              label = "SYNCTHING";
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = config.services.syncthing.dataDir;
              };
            };
          };
        };
      };
    };
  };
}
