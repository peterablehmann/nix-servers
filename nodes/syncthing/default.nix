{
  config,
  inputs,
  ...
}:
{
  imports = [
    ./disko.nix
    ./hardware-configuration.nix
  ];

  metadata = {
    hostName = "syncthing";
    domain = "xnee.net";
    provider = "proxmox.xnee.net";
    network = {
      ipv4 = {
        address = "192.168.48.11";
        prefixLength = 24;
        gateway = "192.168.48.1";
      };
      ipv6 = {
        address = "2a01:4f8:1b7:731::b";
        prefixLength = 64;
        gateway = "2a01:4f8:1b7:731::1";
      };
    };
  };
  services = {
    qemuGuest.enable = true;
    syncthing = {
      enable = true;
      dataDir = "/var/lib/syncthing";
      guiAddress = "[::]:8384";
      settings = {
        devices = {
          kleeblatt = {
            name = "kleeblatt.xnee.net";
            id = "MQEWSP3-AFQR3BI-QZFQWOH-YYGUU4Q-MUUIBZB-AVWXSW6-CADKHZS-7K633QT";
          };
          hasenpfote = {
            name = "hasenpfote.xnee.net";
            id = "LAXQGRV-P7YOQLX-OACH3ZD-RHOQHFI-T233PKG-FKVKOMM-HQHM2FT-E7P6FAV";
          };
          sleipnir = {
            name = "sleipnir.xnee.net";
            id = "KF4KT6E-7QKG6E6-XI62EOV-PYXNGBS-FYYGWN7-QES3TLA-24K75HH-ZPRSIQ3";
          };
        };
        folders = {
          keepass = {
            id = "56n2x-jhoz6";
            path = "~/keepass";
            devices = [
              "kleeblatt"
              "hasenpfote"
              "sleipnir"
            ];
          };
          obsidianvault = {
            id = "esczl-qkfaz";
            path = "~/obsidianvault";
            devices = [
              "kleeblatt"
              "hasenpfote"
              "sleipnir"
            ];
          };
          dcim = {
            id = "vpehd-xcue1";
            path = "~/dcim";
            devices = [
              "kleeblatt"
              "hasenpfote"
              "sleipnir"
            ];
          };
        };
      };
    };
  };

  backup.paths = [ config.services.syncthing.dataDir ];
}
