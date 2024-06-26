{ config
, ...
}:
let
  domain = "sync.xnee.net";
in
{
  security.acme.certs."${domain}" = { };
  networking.domains.subDomains.${domain} = { };

  services.nginx.virtualHosts."${domain}" = {
    useACMEHost = domain;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://${config.services.syncthing.guiAddress}";
    };
  };

  services.syncthing = {
    enable = true;
    dataDir = "/data/syncthing";
    guiAddress = "127.0.0.1:8384";
    settings = {
      gui.insecureSkipHostcheck = true;
      devices = {
        kleeblatt = {
          name = "kleeblatt.xnee.net";
          id = "5UXRXPX-IC4KO4H-E5KFHRI-ROKQBI4-IORXZZN-S5HHRP2-QSVNN3I-MTQIEAU";
        };
        hasenpfote = {
          name = "hasenpfote.xnee.net";
          id = "LAXQGRV-P7YOQLX-OACH3ZD-RHOQHFI-T233PKG-FKVKOMM-HQHM2FT-E7P6FAV";
        };
        tab_s8_xnee_de = {
          name = "Tab S8";
          id = "TWRW63W-65RC4D4-76XRSPS-RCLMBF2-4W3GLAV-4M2DN36-R3BHNZM-ZXDLQAB";
        };
        sleipnir = {
          name = "sleipnir.xnee.net";
          id = "7LVG6JG-N7GRS45-B3THPPH-THPNTKJ-SHL5PX2-AMEVKWP-F24PED6-74CWNAV";
        };
      };
      folders = {
        keepass = {
          id = "56n2x-jhoz6";
          path = "~/keepass";
          devices = [ "kleeblatt" "hasenpfote" "tab_s8_xnee_de" "sleipnir" ];
        };
        obsidianvault = {
          id = "esczl-qkfaz";
          path = "~/obsidianvault";
          devices = [ "kleeblatt" "hasenpfote" "tab_s8_xnee_de" "sleipnir" ];
        };
        dcim = {
          id = "vpehd-xcue1";
          path = "~/dcim";
          devices = [ "kleeblatt" "hasenpfote" "tab_s8_xnee_de" "sleipnir" ];
        };
      };
    };
  };
}
