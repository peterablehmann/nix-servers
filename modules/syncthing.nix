{
  config,
  ...
}:
{
  services.syncthing = {
    enable = true;
    dataDir = "/var/lib/syncthing";
    guiAddress = "[::1]:8384";
    settings = {
      devices = {
        kleeblatt = {
          name = "kleeblatt.xnee.net";
          id = "P64NXCA-DQUEGAU-E7DVZOG-RLJARMF-Y6L6ADF-KHDJINR-O6KWLWA-QSOJHAA";
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

  backup.paths = [ config.services.syncthing.dataDir ];
}
